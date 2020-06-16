import Foundation


public struct EMLFile {
	public struct Header {
		enum HeaderError: Error {
			case invalidStringData
		}

		private var headerPairs: [String: String]

		public var allPairs: [String: String] {
			headerPairs
		}

		public var allKeys: [String] {
			Array(headerPairs.keys)
		}

		public init(data: Data) throws {
			guard let string = String(data: data, encoding: .utf8) else {
				throw HeaderError.invalidStringData
			}
			self.init(rawString: string)
		}

		public init(rawString: String) {
			let lines = rawString.split(separator: "\n", omittingEmptySubsequences: false)

			var lastKey: String?

			var headerCache = [String: String]()

			for line in lines {
				let clean: String
				if line.hasSuffix("\r") {
					clean = String(line.dropLast())
				} else {
					clean = String(line)
				}

				// check if folded line or header is ended:
				guard let firstCharacter = clean.first?.unicodeScalars.first else { break }
				if CharacterSet.whitespacesAndNewlines.contains(firstCharacter), let lastKey = lastKey {
					// is folded
					let trimmed = clean.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
					headerCache[lastKey, default: ""] += " \(trimmed)"
					continue
				}

				if let colon = clean.firstIndex(of: ":") {
					let key = String(clean[clean.startIndex..<colon])
					let nextIndex = clean.index(after: colon)
					let value = clean[nextIndex...].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
					lastKey = key
					headerCache[key] = String(value)
				}
			}
			headerPairs = headerCache
		}

		public init() {
			headerPairs = [:]
		}

		public func value(for key: String) -> String? {
			headerPairs[key]
		}

		public mutating func setValue(for key: String, value: String) {
			headerPairs[key] = value
		}

		public subscript(key: String) -> String? {
			get { headerPairs[key] }
			set  {
				headerPairs[key] = newValue
			}
		}
	}

	struct Body {

	}


}
