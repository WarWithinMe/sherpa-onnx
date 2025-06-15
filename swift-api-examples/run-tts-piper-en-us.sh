#!/usr/bin/env bash

set -ex

# Check if the main build directory for Swift macOS artifacts exists
if [ ! -d ../build-swift-macos ]; then
  echo "The directory ../build-swift-macos was not found."
  echo "Please run ../build-swift-macos.sh from the repository root first to build Swift libraries."
  exit 1
fi

# Define the model directory and name
MODEL_DIR="./piper-en-us-amy-low"
ONNX_MODEL_NAME="en_US-amy-low.onnx"
JSON_MODEL_NAME="en_US-amy-low.onnx.json"

# Check if model files exist, if not, download them
# Using Hugging Face model URLs for Piper voices
if [ ! -f "${MODEL_DIR}/${ONNX_MODEL_NAME}" ] || [ ! -f "${MODEL_DIR}/${JSON_MODEL_NAME}" ]; then
  echo "Downloading Piper model: en_US-amy-low"
  mkdir -p "${MODEL_DIR}"

  # Download ONNX model file
  if [ ! -f "${MODEL_DIR}/${ONNX_MODEL_NAME}" ]; then
    curl -SL -o "${MODEL_DIR}/${ONNX_MODEL_NAME}" \
      "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/low/${ONNX_MODEL_NAME}"
  fi

  # Download JSON model config file
  if [ ! -f "${MODEL_DIR}/${JSON_MODEL_NAME}" ]; then
    curl -SL -o "${MODEL_DIR}/${JSON_MODEL_NAME}" \
      "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/low/${JSON_MODEL_NAME}"
  fi

  echo "Model download complete."
else
  echo "Piper model ${MODEL_DIR} already exists. Skipping download."
fi

# Define the output executable name
EXECUTABLE_NAME="./tts-piper-en-us"

# Compile the Swift code if the executable does not exist
if [ ! -f "${EXECUTABLE_NAME}" ]; then
  echo "Compiling Swift code..."
  # Note: We use -lc++ to link against libc++ instead of libstdc++
  # The paths for include and lib are relative to the script's location (swift-api-examples)
  swiftc \
    -lc++ \
    -I ../build-swift-macos/install/include \
    -import-objc-header ./SherpaOnnx-Bridging-Header.h \
    ./tts-piper-en-us.swift ./SherpaOnnx.swift \
    -L ../build-swift-macos/install/lib/ \
    -l sherpa-onnx \
    -l onnxruntime \
    -o "${EXECUTABLE_NAME}"

  # Optional: strip the executable to reduce size
  strip "${EXECUTABLE_NAME}"
  echo "Compilation successful. Executable: ${EXECUTABLE_NAME}"
else
  echo "Executable ${EXECUTABLE_NAME} already exists. Skipping compilation."
fi

# Set the dynamic library path for the execution
export DYLD_LIBRARY_PATH="../build-swift-macos/install/lib:${DYLD_LIBRARY_PATH}"

# Run the compiled Swift program
echo "Running the TTS example..."
"${EXECUTABLE_NAME}"
echo "TTS example finished."
