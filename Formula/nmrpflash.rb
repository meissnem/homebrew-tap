class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/refs/tags/v0.9.22.tar.gz"
  sha256 "cef3b54c798a4a049a2d9b959e1d6a0ac2f4f31b802d6be4f79351b9a96c3f39"

  depends_on :macos

  def install
    mkdir_p prefix/"bin"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "true"
  end
end
