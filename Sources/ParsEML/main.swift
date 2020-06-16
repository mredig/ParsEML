import Foundation
import ParsEMLCore


let command = CommandLine.arguments[1]
//guard let command = CommandLine.arguments[1] else {
//	print("Need a file.")
//	exit(1)
//}

print(command)

let file = try Data(contentsOf: URL(fileURLWithPath: command))
let string = String(data: file, encoding: .utf8)!

let header = EMLFile.Header(rawString: string)

header.allPairs.forEach {
	print("\($0.key): \($0.value)")
}

//file.
