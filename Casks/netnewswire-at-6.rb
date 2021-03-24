cask "netnewswire-at-6" do
  version "6.0b4,6024"
  sha256 "d796d90e87df8388495a39455dd7ff4a5f3ac81599455586b0677b88beb729cf"

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
