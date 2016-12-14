import Foundation

func json(fromFile file: String) -> Any? {
  let url = URL(fileURLWithPath: "Tests/HarvestAPITests/JSON/\(file).json")
  let data = try! Data(contentsOf: url)
  return JSONObjectWithData(fromData: data)
}

private func JSONObjectWithData(fromData data: Data) -> Any? {
  return try? JSONSerialization.jsonObject(with: data, options: [])
}
