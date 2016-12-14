import PackageDescription

let package = Package(
    name: "HarvestAPI",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git",
                 majorVersion: 3),
        .Package(url: "https://github.com/Alamofire/Alamofire.git",
                 majorVersion: 4),
        .Package(url: "https://github.com/thoughtbot/Argo.git",
                 majorVersion: 4),
    ]
)
