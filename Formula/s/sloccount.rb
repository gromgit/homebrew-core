class Sloccount < Formula
  desc "Count lines of code in many languages"
  homepage "https://dwheeler.com/sloccount/"
  url "https://dwheeler.com/sloccount/sloccount-2.26.tar.gz"
  sha256 "fa7fa2bbf2f627dd2d0fdb958bd8ec4527231254c120a8b4322405d8a4e3d12b"
  license "GPL-2.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?sloccount[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  no_autobump! because: :requires_manual_review

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "3243d86a2a6a558e56911fe743461644ff484b699d962c7afcb17ffed89b7706"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "771db84b98f13ab52ae1a7e8aecef3d193b317b916923562d6a44e36a460dffc"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b0a3aa39555a21889bb78e1826ba3842915234a4728497877ecf83a7520bd7c1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "766075d5d849b025e286d211468d3f8bb3c92e2d1b53ad268db579dcf0049c90"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "73dc2aea90c8e3e1b98e8577e1e4a65758c814d200e3ec49bc4d0fcdc52fc49f"
    sha256 cellar: :any_skip_relocation, sonoma:         "9ce138f5619361b9854cf3b87afd74a2197905bd32f83f72a397f00b33f96363"
    sha256 cellar: :any_skip_relocation, ventura:        "91c5b078ea11fefc9773d823f09438797d676239a78d9a3560c817835e69e86e"
    sha256 cellar: :any_skip_relocation, monterey:       "37029946a07912e8589dafd840596aa9af72b6d77b9d7cf377b4d540411eefa1"
    sha256 cellar: :any_skip_relocation, big_sur:        "edbc1a2e53d527f8230fedce1dafb95d2be651ef0817ea0c9c3c0abc417a0317"
    sha256 cellar: :any_skip_relocation, catalina:       "11a3ecc7f2a5bbc0f2bb4836e03c799049b3bada8438220dcd827ca37fd2a200"
    sha256 cellar: :any_skip_relocation, mojave:         "b9a52de5de2a1be5fd606412ab8db8a55279da49d79f9812d59294a587aaa7c4"
    sha256 cellar: :any_skip_relocation, high_sierra:    "04a4c12a83cb655a8f2f69178905af19e2786927ef7a4e9d0020e870ce35fcbd"
    sha256 cellar: :any_skip_relocation, arm64_linux:    "67092a284463dddf38fd1df78c07816f179261af83cdfae8efa3144c41f9225a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c4d3a2cf9fd5c3dcdc5de48fab3ee4c799f825c2f727c4e090964f398e3084a8"
  end

  uses_from_macos "flex" => :build

  patch do
    url "https://sourceforge.net/p/sloccount/patches/21/attachment/sloccount-suppress-exec-warnings.patch"
    sha256 "4e68a7d9c61d62d4b045d1e5d099c6853456d15f874d659f3ab473e7fc40d565"
  end

  patch :DATA

  def install
    rm "makefile.orig" # Delete makefile.orig or patch falls over
    bin.mkpath # Create the install dir or install falls over
    system "make", "install", "PREFIX=#{prefix}"
    (bin/"erlang_count").write "#!/bin/sh\ngeneric_count '%' $@"
  end

  test do
    system bin/"sloccount", "--version"
  end
end

__END__
diff --git a/break_filelist b/break_filelist
index ad2de47..ff854e0 100755
--- a/break_filelist
+++ b/break_filelist
@@ -205,6 +205,7 @@ $noisy = 0;            # Set to 1 if you want noisy reports.
   "hs" => "haskell", "lhs" => "haskell",
    # ???: .pco is Oracle Cobol
   "jsp" => "jsp",  # Java server pages
+  "erl" => "erlang",
 );
