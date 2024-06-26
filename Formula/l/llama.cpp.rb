class LlamaCpp < Formula
  desc "LLM inference in C/C++"
  homepage "https://github.com/ggerganov/llama.cpp"
  # CMake uses Git to generate version information.
  url "https://github.com/ggerganov/llama.cpp.git",
      tag:      "b3003",
      revision: "d298382ad977ec89c8de7b57459b9d7965d2c272"
  version "b3003"
  license "MIT"
  head "https://github.com/ggerganov/llama.cpp.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "8393f0f181d2e4874d6de3c2134ccde0f843dbdfefb5aa647acc0dd01629fecb"
    sha256 cellar: :any,                 arm64_ventura:  "2869e829ff336df54b963f290a55a9093e43c961301b25e4aac799c2cc32f12b"
    sha256 cellar: :any,                 arm64_monterey: "6d01d125f7366d138e91c2e1d2b7c7017f6673efa349b58d0abffc12f153b855"
    sha256 cellar: :any,                 sonoma:         "cc27f441a2ca1a8514b00b470affd3bee28e7a0f6bd3ab8cd297e6344f384a4a"
    sha256 cellar: :any,                 ventura:        "6ad4b827154f548407ff12bd569aa1bc37ca787873d74a00b7763a7e0beb687a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d76e6219a8d3b76b8736724f2904d59895db7b0b4bd32dcc7098fada637fc69c"
  end

  depends_on "cmake" => :build
  uses_from_macos "curl"

  on_linux do
    depends_on "openblas"
  end

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DLLAMA_LTO=ON
      -DLLAMA_CCACHE=OFF
      -DLLAMA_ALL_WARNINGS=OFF
      -DLLAMA_NATIVE=#{build.bottle? ? "OFF" : "ON"}
      -DLLAMA_ACCELLERATE=#{OS.mac? ? "ON" : "OFF"}
      -DLLAMA_BLAS=#{OS.linux? ? "ON" : "OFF"}
      -DLLAMA_BLAS_VENDOR=OpenBLAS
      -DLLAMA_METAL=#{OS.mac? ? "ON" : "OFF"}
      -DLLAMA_METAL_EMBED_LIBRARY=ON
      -DLLAMA_CURL=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    args << "-DLLAMA_METAL_MACOSX_VERSION_MIN=#{MacOS.version}" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    libexec.install bin.children
    libexec.children.each do |file|
      next unless file.executable?

      new_name = if file.basename.to_s == "main"
        "llama"
      else
        "llama-#{file.basename}"
      end

      bin.install_symlink file => new_name
    end
  end

  test do
    system bin/"llama", "--hf-repo", "ggml-org/tiny-llamas",
                        "-m", "stories15M-q4_0.gguf",
                        "-n", "400", "-p", "I", "-ngl", "0"
  end
end
