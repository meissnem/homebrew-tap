class Diskspace < Formula
  desc "macOS command-line tool to return the available disk space on APFS volumes"
  homepage "https://github.com/scriptingosx/diskspace"
  url "https://github.com/scriptingosx/diskspace/releases/download/v1/diskspace-1.pkg"
  sha256 "918e9796e3390b2644efd4deb36d4095599be5372fddc8536f91bfeba01f66ee"
  license "Apache-2.0"

  depends_on :macos

  def install
    system "pkgutil", "--expand-full", "diskspace-1.pkg", "tmp"
    bin.install "tmp/Payload/usr/local/bin/diskspace"
  end

  test do
    system "true"
  end
end
