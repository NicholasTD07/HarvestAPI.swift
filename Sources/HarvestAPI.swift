import Foundation

import Alamofire

import Argo
import Curry
import Runes

public enum Router {
    case whoami
    case today
    case day(at: Date)
    case addEntry

    public func request(forCompany company: String) throws -> URLRequest {
        let baseURL = try "https://\(company).harvestapp.com/".asURL()

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

public enum API {

}

public enum Model {
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
