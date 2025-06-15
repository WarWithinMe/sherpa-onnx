// GreedySearchDecoder.swift
// SenseVoiceSwift

import Foundation

/// A simple greedy search decoder for processing model output logits.
public struct GreedySearchDecoder {

    public init() {} // Default initializer

    /// Decodes a sequence of logits into a string of tokens.
    /// - Parameters:
    ///   - logits: A 2D array where each inner array represents the logits for a timestep.
    ///   - tokenParser: The TokenParser instance to map token IDs to token strings.
    /// - Returns: The decoded string.
    public func decode(logits: [[Float]], tokenParser: TokenParser) -> String {
        var resultTokens: [String] = []

        for timestepLogits in logits {
            guard !timestepLogits.isEmpty else { continue }

            var bestTokenId: Int = 0
            var maxProb = timestepLogits[0]

            for i in 1..<timestepLogits.count {
                if timestepLogits[i] > maxProb {
                    maxProb = timestepLogits[i]
                    bestTokenId = i
                }
            }

            // TODO: Add logic to handle blank tokens, repeated tokens, etc., based on CTC or transducer rules.
            // For now, just appends the token if found.
            if let token = tokenParser.token(for: bestTokenId) {
                // Simple concatenation for now. Real decoding might involve handling blanks, merging repeats etc.
                // Also, need to consider when to add spaces between words if tokens are sub-word units.
                resultTokens.append(token)
            }
        }

        // Join tokens. For simple character-based models, this might be direct concatenation.
        // For BPE/WordPiece, further processing might be needed (e.g., joining pieces, removing special chars).
        return resultTokens.joined()
    }
}
