// TokenParser.swift
// SenseVoiceSwift

import Foundation

/// Parses a tokens.txt file and provides methods for token/ID lookup.
public class TokenParser {
    private var tokenToId: [String: Int] = [:]
    private var idToToken: [Int: String] = [:]

    /// Initializes the token parser by loading tokens from the given file path.
    /// - Parameter tokensPath: The file path to the tokens.txt file.
    ///   Each line in tokens.txt should be in the format: token<space>id
    public init(tokensPath: String) throws {
        do {
            let content = try String(contentsOfFile: tokensPath, encoding: .utf8)
            let lines = content.split(whereSeparator: \.isNewline)

            for line in lines {
                let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                if parts.count == 2 {
                    let token = String(parts[0])
                    if let id = Int(parts[1]) {
                        tokenToId[token] = id
                        idToToken[id] = token
                    } else {
                        print("Warning: Could not parse token ID for line: \(line)")
                    }
                } else if !line.isEmpty {
                    print("Warning: Malformed line in tokens file: \(line)")
                }
            }
        } catch {
            print("Error reading or processing tokens file at '\(tokensPath)': \(error)")
            // Depending on desired behavior, could rethrow, or leave dictionaries empty
            // For now, we allow initialization with empty dictionaries if file loading fails.
            // throw error // Uncomment to make file loading a hard requirement
        }
    }

    /// Looks up the token string for a given token ID.
    /// - Parameter tokenId: The ID of the token.
    /// - Returns: The token string, or nil if the ID is not found.
    public func token(for tokenId: Int) -> String? {
        return idToToken[tokenId]
    }

    /// Looks up the token ID for a given token string.
    /// - Parameter token: The token string.
    /// - Returns: The token ID, or nil if the token is not found.
    public func tokenId(for token: String) -> Int? {
        return tokenToId[token]
    }
}
