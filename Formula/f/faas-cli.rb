class FaasCli < Formula
  desc "CLI for templating and/or deploying FaaS functions"
  homepage "https://www.openfaas.com/"
  url "https://github.com/openfaas/faas-cli/archive/refs/tags/0.16.36.tar.gz"
  sha256 "7892f92c82b41c887ae4ef0a8e361a449a0f4e1ffb91de758432ce9a79242d45"
  license "MIT"
  head "https://github.com/openfaas/faas-cli.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "758bd68ebe568f7efc66e9859afa0f101d5a0a5fbf4faa3b13e09a4a6db56d5d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "758bd68ebe568f7efc66e9859afa0f101d5a0a5fbf4faa3b13e09a4a6db56d5d"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "758bd68ebe568f7efc66e9859afa0f101d5a0a5fbf4faa3b13e09a4a6db56d5d"
    sha256 cellar: :any_skip_relocation, sonoma:        "7271203bb10e20e51ff2191928da04f5e1ed273e5abb6386dab46e0992011f1f"
    sha256 cellar: :any_skip_relocation, ventura:       "7271203bb10e20e51ff2191928da04f5e1ed273e5abb6386dab46e0992011f1f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "452fa324104a3ad5743aee949c8386732b0572783dc24baaea6403a36fa6764f"
  end

  depends_on "go" => :build

  def install
    ENV["XC_OS"] = OS.kernel_name.downcase
    ENV["XC_ARCH"] = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    project = "github.com/openfaas/faas-cli"
    ldflags = %W[
      -s -w
      -X #{project}/version.GitCommit=
      -X #{project}/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "-a", "-installsuffix", "cgo"
    bin.install_symlink "faas-cli" => "faas"

    generate_completions_from_executable(bin/"faas-cli", "completion", "--shell", shells: [:bash, :zsh])
    # make zsh completions also work for `faas` symlink
    inreplace zsh_completion/"_faas-cli", "#compdef faas-cli", "#compdef faas-cli\ncompdef faas=faas-cli"
  end

  test do
    require "socket"

    server = TCPServer.new("localhost", 0)
    port = server.addr[1]
    pid = fork do
      loop do
        socket = server.accept
        response = "OK"
        socket.print "HTTP/1.1 200 OK\r\n" \
                     "Content-Length: #{response.bytesize}\r\n" \
                     "Connection: close\r\n"
        socket.print "\r\n"
        socket.print response
        socket.close
      end
    end

    (testpath/"test.yml").write <<~EOS
      provider:
        name: openfaas
        gateway: https://localhost:#{port}
        network: "func_functions"

      functions:
        dummy_function:
          lang: python
          handler: ./dummy_function
          image: dummy_image
    EOS

    begin
      output = shell_output("#{bin}/faas-cli deploy --tls-no-verify -yaml test.yml 2>&1", 1)
      assert_match "stat ./template/python/template.yml", output

      assert_match "ruby", shell_output("#{bin}/faas-cli template pull 2>&1")
      assert_match "node", shell_output("#{bin}/faas-cli new --list")

      output = shell_output("#{bin}/faas-cli deploy --tls-no-verify -yaml test.yml", 1)
      assert_match "Deploying: dummy_function.", output

      faas_cli_version = shell_output("#{bin}/faas-cli version")
      assert_match version.to_s, faas_cli_version
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
