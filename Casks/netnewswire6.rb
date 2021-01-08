cask "netnewswire6" do
  version "6.0d2"
  sha256 "f34304abb06fe83055d4dc08a02cb4310e65fa1a88353abb1544c1e63035b2b6"

  url "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-#{version}/NetNewsWire#{version}.zip",
      verified: "https://github.com/Ranchero-Software/NetNewsWire/releases/download"
  appcast "https://ranchero.com/downloads/netnewswire6-beta.xml"
  name "NetNewsWire 6 (In Development)"
  desc "Free and open-source RSS reader"
  homepage "https://ranchero.com/netnewswire/"

  app "NetNewsWire.app"
end
