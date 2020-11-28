class Nmrpflash < Formula
  desc "Netgear Unbrick Utility"
  homepage "https://github.com/jclehner/nmrpflash"
  url "https://github.com/jclehner/nmrpflash/archive/v0.9.13.tar.gz"
  sha256 "33cdb7cae2083e7f45f709235e379f8a77fa0bcca51c0f7aafbf322a54d2a154"

  bottle do
    root_url "https://github.com/meissnem/homebrew-meissnem/releases/download/nmrpflash-0.9.13"
    cellar :any_skip_relocation
    sha256 "123d158f3d96d2ebf2cc9fd043ebe04384eff4acbbc9592c5a5929079e486097" => :big_sur
  end

  def install
    mkdir_p prefix/"bin"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "false"
  end
end
