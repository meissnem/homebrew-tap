cask "netnewswire-beta" do
  version "6.0.1b1,6028"
  sha256 "e73ba43fd587e14de32b055787100c8e9948da29e5088d28f7779b4be845e58f"

  url "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-#{version.before_comma}/NetNewsWire#{version.before_comma}.zip",
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
