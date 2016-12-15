import Argo
import Curry
import Runes

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
