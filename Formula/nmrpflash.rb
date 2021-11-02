class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/v0.9.16.tar.gz"
  sha256 "ccb5974a9574f0ce361f8d2d68f743957a44c9e27dc9490589e8f91c9f8f6bb6"

  bottle do
    root_url "https://github.com/meissnem/homebrew-meissnem/releases/download/nmrpflash-0.9.16"
    sha256 cellar: :any_skip_relocation, big_sur: "123d158f3d96d2ebf2cc9fd043ebe04384eff4acbbc9592c5a5929079e486097"
  end

  def install
    mkdir_p prefix/"bin"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "false"
  end
end
