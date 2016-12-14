import Argo
import Curry
import Runes

public enum Model {
    public struct Project {
        public let id: Int
        public let name: String
        public let billable: Bool
        /* public let tasks: [Task] */
    }

    public struct Task {
        public let id: Int
        public let name: String
        public let billable: Bool
    }
}

extension Model.Project: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Model.Project> {
        return curry(Model.Project.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "billable"
            /* <*> j <| "tasks" */
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
    entry_payload = {
        'notes': notes,
        'hours': hours,
        'project_id': project.id,
        'task_id': task.id,
        'spent_at': spent_at,
    }

    class Project(JSONDeserilizable):
        __desired_keys__ = ['name', 'id', 'billable']
        tasks = None

    class Task(JSONDeserilizable):
        __desired_keys__ = ['name', 'id', 'billable']

    class Entry(JSONDeserilizable):
        __desired_keys__ = [
            'id',
            'hours',
            'notes',
            'client',
            'spent_at', # u'spent_at': u'2016-08-10',

            'project',
            'project_id',
            'task',
            'task_id',
        ]
    */
