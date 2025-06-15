class MyClass {
  func playSamples(samples: [Float]) {
    // This is a placeholder. In a real application, you would play the audio.
    // For this example, we'll just print the number of samples.
    print("Received \(samples.count) audio samples.")
    // If you want to save to a file or do other processing, you can do it here.
  }
}

func run() {
  // Define paths for Piper model
  // These paths assume the model files are in a subdirectory named "piper-en-us-amy-low"
  // relative to the execution directory of the script.
  let model = "./piper-en-us-amy-low/en_US-amy-low.onnx"
  let modelConfig = "./piper-en-us-amy-low/en_US-amy-low.onnx.json"

  // Configure Piper model using SherpaOnnxOfflineTtsPiperModelConfig
  // More details on parameters can be found in the sherpa-onnx documentation.
  let piperConfig = sherpaOnnxOfflineTtsPiperModelConfig(
    model: model,
    modelConfig: modelConfig,
    dataDir: nil, // dataDir is not typically needed for Piper's universal models
    vocab: nil,   // vocab is often embedded or not needed for Piper
    dictDir: nil, // dictDir is for custom dictionaries, not used here
    noiseScale: 0.667, // Synthesis noise scale
    lengthScale: 1.0,  // Controls speed, 1.0 is normal
    noiseStd: 0.8      // Synthesis noise standard deviation
  )

  // Create the main model configuration using the Piper specific config
  let ttsModelConfig = sherpaOnnxOfflineTtsModelConfig(piper: piperConfig, debug: 0, provider: "cpu", numThreads: 1)

  // Create the TTS configuration object
  var ttsConfig = sherpaOnnxOfflineTtsConfig(model: ttsModelConfig)

  // Create an instance of MyClass to be used with the callback
  let myClass = MyClass()

  // Create an Unmanaged reference to MyClass instance to pass to the C callback
  // This allows the C callback to call a Swift class method.
  // It's crucial that myClass outlives the TTS generation process.
  let arg = Unmanaged<MyClass>.passUnretained(myClass).toOpaque()

  // Define the callback function that will receive audio samples
  let callback: TtsCallbackWithArg = { samples, n, arg in
    // Cast the opaque pointer back to a MyClass instance
    let o = Unmanaged<MyClass>.fromOpaque(arg!).takeUnretainedValue()

    // Create a Swift array from the C array of samples
    var savedSamples: [Float] = []
    if let samplesArray = samples {
        for i in 0..<Int(n) {
            savedSamples.append(samplesArray[i])
        }
    }

    // Call the method on the MyClass instance
    o.playSamples(samples: savedSamples)

    // Return 1 to continue audio generation, 0 to stop
    return 1
  }

  // Initialize the TTS engine wrapper
  let tts = SherpaOnnxOfflineTtsWrapper(config: &ttsConfig)

  // Define the text to synthesize, speaker ID, and speed
  let text = "Hello, this is a test of the Piper text-to-speech engine using SherpaOnnx. I hope this example works correctly."
  let sid = 0 // Speaker ID (if model supports multiple speakers)
  let speed: Float = 1.0 // Playback speed

  print("Starting TTS generation for text: \"\(text)\"")

  // Generate audio. The callback will be invoked with audio chunks.
  let audio = tts.generateWithCallbackWithArg(
    text: text, callback: callback, arg: arg, sid: sid, speed: speed)

  // Save the generated audio to a WAV file
  let filename = "tts-piper-en-us-amy.wav" // Specific filename
  let ok = audio.save(filename: filename)
  if ok == 1 {
    print("Generated audio saved to: \(filename)")
  } else {
    print("Failed to save generated audio to \(filename). Error code: \(ok)")
  }
  print("TTS generation finished.")
}

// Main entry point for the Swift application
@main
struct App {
  static func main() {
    print("Running Piper TTS Swift example...")
    run()
    print("Piper TTS Swift example finished.")
  }
}
