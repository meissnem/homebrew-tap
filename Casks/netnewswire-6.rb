cask "netnewswire-6" do
  version "6.0d5"
  sha256 "74b84ffd48722d3502828736f0d747d1f5d7dd1b010844f519fcf8a1e06184a8"

  url "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-#{version.split('d').first}dev#{version.split('d').last}/NetNewsWire#{version}.zip",
    verified: "https://github.com/Ranchero-Software/NetNewsWire/"
  appcast "https://ranchero.com/downloads/netnewswire6-beta.xml"
  name "NetNewsWire"
  desc "Free and open-source RSS reader"
  homepage "https://ranchero.com/netnewswire/"

  auto_updates true
#  conflicts_with cask: "netnewswire"

  depends_on macos: ">= :catalina"

  app "NetNewsWire.app"
end
