class Pmd < Formula
  desc "Source code analyzer for Java, JavaScript, and more"
  homepage "https://pmd.github.io"
  url "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.1.0/pmd-dist-7.1.0-bin.zip"
  sha256 "0d31d257450f85d995cc87099f5866a7334f26d6599dacab285f2d761c049354"
  license "BSD-4-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "bc1cbdce66b9dfa7b0952f6329aa3c6f0e5ef613de09ebd992f6b5bae4e18a6f"
  end

  depends_on "openjdk"

  def install
    rm Dir["bin/*.bat"]
    libexec.install Dir["*"]
    (bin/"pmd").write_env_script libexec/"bin/pmd", Language::Java.overridable_java_home_env
  end

  test do
    (testpath/"java/testClass.java").write <<~EOS
      public class BrewTestClass {
        // dummy constant
        public String SOME_CONST = "foo";

        public boolean doTest () {
          return true;
        }
      }
    EOS

    output = shell_output("#{bin}/pmd check -d #{testpath}/java " \
                          "-R category/java/bestpractices.xml -f json")
    assert_empty JSON.parse(output)["processingErrors"]
  end
end
