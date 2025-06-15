// SenseVoiceConfig.swift
import Foundation
public struct SenseVoiceASRConfig {
    public var modelPath: String
    public var tokensPath: String
    public var language: String
    public var useITN: Bool
    public var numThreads: Int
    public init(modelPath: String, tokensPath: String, language: String = "auto", useITN: Bool = true, numThreads: Int = 1) {
        self.modelPath = modelPath
        self.tokensPath = tokensPath
        self.language = language
        self.useITN = useITN
        self.numThreads = numThreads
    }
}
