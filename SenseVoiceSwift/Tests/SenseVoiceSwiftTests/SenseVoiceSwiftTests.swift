// SenseVoiceSwiftTests.swift
import XCTest
@testable import SenseVoiceSwift // Import the module to be tested

final class TokenParserTests: XCTestCase {
    let dummyTokensPath = "dummy_tokens.txt" // Relative to package root

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Create dummy_tokens.txt before each test
        let tokensContent = "<blank> 0\nhello 1\nworld 2\n<eos> 3\nswift 4\non 5"
        try tokensContent.write(toFile: dummyTokensPath, atomically: true, encoding: .utf8)
    }

    override func tearDownWithError() throws {
        // Remove dummy_tokens.txt after each test
        try? FileManager.default.removeItem(atPath: dummyTokensPath)
        try super.tearDownWithError()
    }

    func testTokenParserInitialization() throws {
        let tokenParser = try TokenParser(tokensPath: dummyTokensPath)
        XCTAssertEqual(tokenParser.token(for: 1), "hello")
        XCTAssertEqual(tokenParser.tokenId(for: "world"), 2)
        XCTAssertEqual(tokenParser.token(for: 4), "swift")
        XCTAssertEqual(tokenParser.tokenId(for: "on"), 5)
        XCTAssertEqual(tokenParser.tokenId(for: "<blank>"), 0)
        XCTAssertEqual(tokenParser.token(for: 3), "<eos>")
        // Check count - should be 6 tokens
        // Accessing internal dictionaries for count is not ideal for black-box testing,
        // but for this specific case, we can infer it by testing known and unknown items.
        XCTAssertNotNil(tokenParser.tokenId(for: "hello"))
        XCTAssertNotNil(tokenParser.tokenId(for: "world"))
        XCTAssertNotNil(tokenParser.tokenId(for: "swift"))
        XCTAssertNotNil(tokenParser.tokenId(for: "on"))
        XCTAssertNotNil(tokenParser.tokenId(for: "<blank>"))
        XCTAssertNotNil(tokenParser.tokenId(for: "<eos>"))
    }

    func testTokenParserUnknown() throws {
        let tokenParser = try TokenParser(tokensPath: dummyTokensPath)
        XCTAssertNil(tokenParser.token(for: 100)) // Unknown ID
        XCTAssertNil(tokenParser.tokenId(for: "unknown_token")) // Unknown token
    }
}

final class GreedySearchDecoderTests: XCTestCase {
    var tokenParser: TokenParser!
    let dummyTokensPath = "dummy_tokens_for_decoder.txt"

    override func setUpWithError() throws {
        try super.setUpWithError()
        let tokensContent = "<blank> 0\nhello 1\nworld 2\n<eos> 3\nswift 4\non 5"
        try tokensContent.write(toFile: dummyTokensPath, atomically: true, encoding: .utf8)
        tokenParser = try TokenParser(tokensPath: dummyTokensPath)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(atPath: dummyTokensPath)
        tokenParser = nil
        try super.tearDownWithError()
    }

    func testGreedySearchDecoderBasic() {
        let logits: [[Float]] = [[0.1, 0.7, 0.1, 0.0, 0.1, 0.0], [0.1, 0.2, 0.0, 0.1, 0.3, 0.3]] // hello, on (IDs 1, 5)
        let decoder = GreedySearchDecoder()
        let result = decoder.decode(logits: logits, tokenParser: tokenParser)
        XCTAssertEqual(result, "helloon") // Simple concatenation without space handling
    }

    func testGreedySearchDecoderWithBlanks() {
        let logits: [[Float]] = [[0.8, 0.1, 0.1, 0.0, 0.0, 0.0], [0.1, 0.7, 0.1, 0.1, 0.0, 0.0], [0.7, 0.1, 0.1, 0.1, 0.0, 0.0]] // <blank>hello<blank>
        let decoder = GreedySearchDecoder()
        let result = decoder.decode(logits: logits, tokenParser: tokenParser)
        XCTAssertEqual(result, "<blank>hello<blank>") // Assumes simple concatenation
    }
}

final class SenseVoiceASRTests: XCTestCase {
    let dummyTokensPath = "dummy_tokens_for_asr.txt"
    let dummyModelPath = "dummy_model_for_asr.onnx"

    override func setUpWithError() throws {
        try super.setUpWithError()
        let tokensContent = "<blank> 0\n<unk> 1\nhello 2\nworld 3\n<sos> 4\n<eos> 5"
        try tokensContent.write(toFile: dummyTokensPath, atomically: true, encoding: .utf8)
        try? Data().write(to: URL(fileURLWithPath: dummyModelPath)) // Empty model file
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(atPath: dummyTokensPath)
        try? FileManager.default.removeItem(atPath: dummyModelPath)
        try super.tearDownWithError()
    }

    func testASRInitialization() throws {
        let config = SenseVoiceASRConfig(modelPath: dummyModelPath, tokensPath: dummyTokensPath)
        XCTAssertNoThrow(try SenseVoiceASR(config: config), "ASR initialization should not throw with dummy files (ONNX part commented out).")
    }

    func testASRTranscribePlaceholder() throws {
        let configEn = SenseVoiceASRConfig(modelPath: dummyModelPath, tokensPath: dummyTokensPath, language: "en", useITN: true)
        let asrEn = try SenseVoiceASR(config: configEn)
        let resultEn = try asrEn.transcribe(features: [], featureLengths: [])
        XCTAssertTrue(resultEn.contains("lang=2"), "Result was: \(resultEn)")
        XCTAssertTrue(resultEn.contains("itn=1"), "Result was: \(resultEn)")

        let configZhFalse = SenseVoiceASRConfig(modelPath: dummyModelPath, tokensPath: dummyTokensPath, language: "zh", useITN: false)
        let asrZh = try SenseVoiceASR(config: configZhFalse)
        let resultZh = try asrZh.transcribe(features: [], featureLengths: [])
        XCTAssertTrue(resultZh.contains("lang=1"), "Result was: \(resultZh)")
        XCTAssertTrue(resultZh.contains("itn=0"), "Result was: \(resultZh)")
    }
}
