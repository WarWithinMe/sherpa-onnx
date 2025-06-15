// main.swift for SenseVoiceSwift
import Foundation

@main
struct SenseVoiceApp {
    static func main() {
        print("Starting SenseVoiceSwift test...")

        // Dummy paths for initialization test
        let dummyModelPath = "./dummy_model.onnx" // Will be created as an empty file
        let dummyTokensPath = "./tokens.txt"   // Will be created with some content

        // Create dummy files to allow initialization to proceed further
        do {
            let tokensContent = "<blank> 0\n<unk> 1\nhello 2\nworld 3\n<sos> 4\n<eos> 5"
            try tokensContent.write(toFile: dummyTokensPath, atomically: true, encoding: .utf8)
            print("Created dummy tokens file at: \(dummyTokensPath)")

            // Create an empty dummy model file as ONNX session is commented out
            try Data().write(to: URL(fileURLWithPath: dummyModelPath))
            print("Created dummy model file at: \(dummyModelPath)")
        } catch {
            print("Error creating dummy files: \(error)")
        }

        let config = SenseVoiceASRConfig(
            modelPath: dummyModelPath,
            tokensPath: dummyTokensPath,
            language: "en",
            useITN: true,
            numThreads: 1
        )
        print("SenseVoiceASRConfig created.")

        do {
            print("Attempting to initialize SenseVoiceASR...")
            let asr = try SenseVoiceASR(config: config) // This will now also init GreedySearchDecoder
            print("SenseVoiceASR initialized successfully.")

            // Test transcribe method placeholder
            let dummyFeatures: [[Float]] = [[0.1, 0.8, 0.1, 0.0, 0.0, 0.0], [0.7, 0.2, 0.1, 0.0, 0.0, 0.0]] // Example features
            let dummyFeatureLengths: [Int] = [2] // Example length for one sequence
            print("Calling transcribe...")
            let transcription = try asr.transcribe(features: dummyFeatures, featureLengths: dummyFeatureLengths)
            print("Transcription result: '\(transcription)'")
        } catch {
            print("Error during SenseVoiceASR usage: \(error)")
        }

        // Clean up dummy files
        do {
            try FileManager.default.removeItem(atPath: dummyModelPath)
            print("Cleaned up dummy model file.")
            try FileManager.default.removeItem(atPath: dummyTokensPath)
            print("Cleaned up dummy tokens file.")
        } catch {
            print("Error cleaning up dummy files: \(error)")
        }

        print("SenseVoiceSwift test finished.")
    }
}
