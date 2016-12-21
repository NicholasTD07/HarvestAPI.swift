import Foundation

import enum Alamofire.HTTPMethod
import class Alamofire.SessionManager
import class Alamofire.Request
import enum Result.Result

import Argo
import Curry
import Runes

public protocol APIType {
    typealias DayHandler = (_ date: Date) -> (_: Result<Model.Day, API.Error>) -> Void
    typealias ProjectsHandler = (_: Result<[Model.Project], API.Error>) -> Void
    typealias UserHandler = (_: Result<Model.User, API.Error>) -> Void

    func days(_ days: [Date], handler: @escaping APIType.DayHandler)
    func day(at date: Date, handler: @escaping APIType.DayHandler)
    func projects(handler: @escaping ProjectsHandler)
    func user(handler: @escaping UserHandler)
}

extension API {
    public enum Error: Swift.Error {
        case networkFailed(Swift.Error)
        case decodingFailed(DecodeError)
    }
}

public struct API: APIType {
    public typealias HTTPBasicAuth = (username: String, password: String)

    public let company: String
    private let auth: HTTPBasicAuth

    private let sessionManager: SessionManager

    public init(company: String, auth: HTTPBasicAuth) {
        self.company = company
        self.auth = auth

        let configuration = URLSessionConfiguration.default
        let authorizationHeader = Request.authorizationHeader(
            user: auth.username,
            password: auth.password
        )!

        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            authorizationHeader.key: authorizationHeader.value,
        ]

        self.sessionManager = SessionManager(configuration: configuration)
    }

    public func days(_ days: [Date], handler: @escaping APIType.DayHandler) {
        days.forEach { day(at: $0, handler: handler) }
    }

    public func day(at date: Date, handler: @escaping APIType.DayHandler) {
        request(Router.day(at: date), with: handler(date))
    }

    public func projects(handler: @escaping APIType.ProjectsHandler) {
        request(Router.today) { (result: Result<Model.Day, API.Error>) in
            switch result {
            case let .success(day):
                handler(.success(day.projects))
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    public func user(handler: @escaping APIType.UserHandler) {
        request(Router.whoami, with: handler)
    }

    private func request<Value>(_ route: Router, with handler: @escaping (_: Result<Value, API.Error>) -> Void)
        where Value: Decodable, Value.DecodedType == Value {
            sessionManager.request(route.request(forCompany: company))
                .responseJSON { response in
                    guard let json = response.result.value else {
                        handler(.failure(.networkFailed(response.result.error!)))

                        return
                    }

                    let decoded: Decoded<Value> = decode(json)

                    switch decoded {
                    case let .success(value):
                        handler(.success(value))
                    case let .failure(decodeError):
                        handler(.failure(.decodingFailed(decodeError)))
                    }
            }
    }

    // Note: This is here for requesting `[Decodable]` types
    //       Difference to the one above is where `Value` is used, it is replaced with `[Value]`
    // FIXME: Investigate whether there's a better/more clever way to solve it
    //        without duplicating 98% of the code
    private func request<Value>(_ route: Router, with handler: @escaping (_: Result<[Value], API.Error>) -> Void)
        where Value: Decodable, Value.DecodedType == Value {
            sessionManager.request(route.request(forCompany: company))
                .responseJSON { response in
                    guard let json = response.result.value else {
                        handler(.failure(.networkFailed(response.result.error!)))

                        return
                    }

                    let decoded: Decoded<[Value]> = decode(json)

                    switch decoded {
                    case let .success(value):
                        handler(.success(value))
                    case let .failure(decodeError):
                        handler(.failure(.decodingFailed(decodeError)))
                    }
            }
    }
}

public enum Router {
    case whoami
    case today
    case day(at: Date)
    case addEntry

    public func request(forCompany company: String) -> URLRequest {
        let baseURL = URL(string: "https://\(company).harvestapp.com")!

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue

        // encode param

        return request
    }

    public var method: HTTPMethod {
        switch self {
        case .whoami, .today, .day:
            return .get
        case .addEntry:
            return .post
        }
    }

    public var path: String {
        switch self {
        case .whoami:
            return "/account/who_am_i"
        case .today:
            return "/daily"
        case let .day(date):
            let day = calendar.ordinality(of: .day, in: .year, for: date)!
            let year = calendar.component(.year, from: date)
            return "/daily/\(day)/\(year)"
        case .addEntry:
            return "/daily/add"
        }
    }
}

private let calendar = Calendar.current

public enum Model {
    public struct User {
        public let firstName: String
        public let lastName: String

        public var name: String {
            return "\(firstName) \(lastName)"
        }
    }
    public struct Day {
        public let dateString: String
        public let entries: [Entry]
        public let projects: [Project]

        public func date() -> Date {
            return Day.dateFormatter.date(from: dateString)!
        }

        public static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
    }

    public struct Entry {
        public let hours: Float
    }

    public struct Project {
        public let id: Int
        public let name: String
        public let billable: Bool
        public let tasks: [Task]
    }

    public struct Task {
        public let id: Int
        public let name: String
        public let billable: Bool
    }
}

extension Model.User: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.User> {
        return curry(Model.User.init)
            <^> json <| ["user", "first_name"]
            <*> json <| ["user", "last_name"]
    }
}

extension Model.Day: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.Day> {
        return curry(Model.Day.init)
            <^> json <| "for_day"
            <*> json <|| "day_entries"
            <*> json <|| "projects"
    }
}

extension Model.Entry: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.Entry> {
        return curry(Model.Entry.init)
            <^> json <| "hours"
    }
}

extension Model.Project: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.Project> {
        return curry(Model.Project.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "billable"
            <*> json <|| "tasks"
    }
}

extension Model.Task: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.Task> {
        return curry(Model.Task.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "billable"
    }
}

extension Model.Project: Equatable { }

public func == (rhs: Model.Project, lhs: Model.Project) -> Bool {
    return rhs.id == lhs.id
}

extension Model.Task: Equatable { }

public func == (rhs: Model.Task, lhs: Model.Task) -> Bool {
    return rhs.id == lhs.id
}

// ViewModel candidates
extension Model.Day {
    public func hours() -> Float {
        return entries.reduce(0) { $0 + $1.hours }
    }
}

extension Model.Project {
    public var description: String {
        let billableString = billable ? "Billable" : "Non-billable"

        return "\(billableString) \(name)"
    }
}

extension Model.Task {
    public var description: String {
        let billableString = billable ? "Billable" : "Non-billable"

        return "\(billableString) \(name)"
    }
}

    /** From: https://github.com/NicholasTD07/TTTTT/blob/master/2016-08---Py---Harvest-Season/harvest_season.py
    entry_post_payload = {
        'notes': notes,
        'hours': hours,
        'project_id': project.id,
        'task_id': task.id,
        'spent_at': spent_at,
    }
    */
