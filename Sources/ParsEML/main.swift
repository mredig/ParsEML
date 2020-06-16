import Foundation
import ParsEMLCore


let command = CommandLine.arguments[1]

let file = try EMLFile(from: URL(fileURLWithPath: command))

file.header.allPairs.forEach {
	print("\($0.key): \($0.value)")
}
