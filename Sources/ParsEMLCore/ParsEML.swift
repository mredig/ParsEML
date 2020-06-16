import Foundation

fileprivate extension UInt8 {
	static let crChar: UInt8 = 0x0D
	static let lfChar: UInt8 = 0x0A
}

public struct EMLFile {
	public let header: Header
	public let body: Body?

	private static let newlines = CharacterSet(arrayLiteral: .init(.crChar), .init(.lfChar))

	public init(from file: URL) throws {
		let fileData = try Data(contentsOf: file)

		var lastChar: UInt8 = 0
		var headerSeparationIndex = fileData.count
		for index in fileData.indices {
			let thisChar = fileData[index]
			defer { lastChar = thisChar }
			guard Self.newlines.contains(.init(thisChar)) else {
				continue
			}

			if Self.newlines.contains(.init(thisChar)) {
				if lastChar == .lfChar {
					headerSeparationIndex = index
					break
				}
			}
		}

		header = try Header(data: fileData[0..<headerSeparationIndex])
		body = try Body(data: fileData[headerSeparationIndex...])
	}


	enum EMLError: Error {
		case invalidStringData
	}

	public struct Header {

		private var headerPairs: [String: String]

		public var allPairs: [String: String] {
			headerPairs
		}

		public var allKeys: [String] {
			Array(headerPairs.keys)
		}

		public init(data: Data) throws {
			guard let string = String(data: data, encoding: .utf8) else {
				throw EMLError.invalidStringData
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

	public struct Body {
		public let body: String

		init(data: Data) throws {
			guard let str = String(data: data, encoding: .utf8) else {
				throw EMLError.invalidStringData
			}
			self.body = str
		}

		init(body: String) {
			self.body = body
		}
	}


}
