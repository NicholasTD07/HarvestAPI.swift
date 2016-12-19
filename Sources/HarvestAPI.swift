import Foundation

import enum Alamofire.HTTPMethod
import class Alamofire.DataRequest
import class Alamofire.SessionManager
import enum Result.Result

import Argo
import Curry
import Runes

public protocol APIType {
    typealias UserResult = Result<Model.User, API.Error>
    typealias UserHandler = (_: UserResult) -> Void

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
        let authorizationHeader = DataRequest.authorizationHeader(
            user: auth.username,
            password: auth.password
        )!

        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            authorizationHeader.key: authorizationHeader.value,
        ]

        self.sessionManager = SessionManager(configuration: configuration)
    }

    public func user(handler: @escaping APIType.UserHandler) {
        let request = Router.whoami.request(forCompany: company)
        self.request(request)
            .responseJSON { response in
                guard let json = response.result.value else {
                    handler(.failure(.networkFailed(response.result.error!)))

                    return
                }

                let decoded: Decoded<Model.User> = decode(json)

                switch decoded {
                case let .success(user):
                    handler(.success(user))
                case let .failure(decodeError):
                    handler(.failure(.decodingFailed(decodeError)))
                }
            }
    }

    public func addEntry(for: (Model.Project, Model.Task), at date: Date) {
        let request = Router.addEntry.request(forCompany: company)
        self.request(request)
    }

    private func request(_ request: URLRequest) -> DataRequest {
        let request = sessionManager.request(request)
        return request
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
            let day = 1 // calendar.ordinality(of: .day, in: year, for: date)
            let year = 2017 // calendar.component(.year, from: date)
            return "/daily/\(day)/\(year)"
        case .addEntry:
            return "/daily/add"
        }
    }
}

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
    /** From: https://github.com/NicholasTD07/TTTTT/blob/master/2016-08---Py---Harvest-Season/harvest_season.py
    entry_post_payload = {
        'notes': notes,
        'hours': hours,
        'project_id': project.id,
        'task_id': task.id,
        'spent_at': spent_at,
    }
    */
