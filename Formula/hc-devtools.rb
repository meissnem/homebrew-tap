class HcDevtools < Formula
  desc "Umbrella formula to install and configure Host Compliance dev tools"
  homepage "https://github.com/VacaAPI"
  url "https://raw.githubusercontent.com/meissnem/homebrew-tap/main/README.md"
  version "1.0.0"
  sha256 "ea0ec809d1776e9e7eef865e206d1797bcfa154b471b4579175709e429cac394"

  keg_only "because nothing real gets installed"

  depends_on "hc-postgis"
  depends_on "hc-postgresql"
  depends_on "hc-redis"

  def install
    bin.mkpath
    prefix.install "README.md"
  end

  test do
    system "true"
  end
end
