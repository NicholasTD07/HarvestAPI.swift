public enum Models {
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
