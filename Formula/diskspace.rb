class Diskspace < Formula
  desc "macOS command-line tool to return the available disk space on APFS volumes"
  homepage "https://github.com/scriptingosx/diskspace"
  url "https://github.com/scriptingosx/diskspace/releases/download/v1/diskspace-1.pkg"
  sha256 "918e9796e3390b2644efd4deb36d4095599be5372fddc8536f91bfeba01f66ee"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/diskspace-1"
    sha256 cellar: :any_skip_relocation, big_sur:  "8a0e7aadd0b61a4e1e0064b072078c0d3df0607375c0764526c590a3616555c6"
    sha256 cellar: :any_skip_relocation, catalina: "1d8338ae1410681f7d3d052ffc2ae29ac5775f85f1087d9fc1249f233477dea5"
  end

  depends_on :macos

  def install
    system "pkgutil", "--expand-full", "diskspace-1.pkg", "tmp"
    bin.install "tmp/Payload/usr/local/bin/diskspace"
  end

  test do
    system "true"
  end
end
