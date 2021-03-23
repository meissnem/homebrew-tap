cask "netnewswireAT6" do
  version "6.0b3,6023"
  sha256 "43e8fc5f925e012d01025d46062b55d409287e09ea36a9b2264e0f5108998aa8"

  url "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-#{version.before_comma.split("b").first}beta#{version.before_comma.split("b").last}/NetNewsWire#{version.before_comma}.zip",
      verified: "https://github.com/Ranchero-Software/NetNewsWire/"
  name "NetNewsWire"
  desc "Free and open-source RSS reader"
  homepage "https://ranchero.com/netnewswire/"

  livecheck do
    url "https://ranchero.com/downloads/netnewswire6-beta.xml"
    strategy :sparkle
  end

  auto_updates true
  # conflicts_with cask: "netnewswire"

  depends_on macos: ">= :catalina"

  app "NetNewsWire.app"
end
