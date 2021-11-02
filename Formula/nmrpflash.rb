class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/v0.9.16.tar.gz"
  sha256 "ccb5974a9574f0ce361f8d2d68f743957a44c9e27dc9490589e8f91c9f8f6bb6"

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/nmrpflash-0.9.16"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "c07a37fadecd4b0890b98cfb9cf02b068745d24bde4c03a9ebd0f24ad741036f"
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
