class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/refs/tags/v0.9.22.tar.gz"
  sha256 "cef3b54c798a4a049a2d9b959e1d6a0ac2f4f31b802d6be4f79351b9a96c3f39"

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/nmrpflash-0.9.22"
    sha256 cellar: :any_skip_relocation, ventura: "3d9b163816b7160ad2480c4c38deb787762c3d06c2294b55c58a9d69982a49b2"
  end

  depends_on :macos

  def install
    mkdir_p prefix/"bin"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "true"
  end
end
