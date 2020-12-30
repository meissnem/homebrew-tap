cask "mimestream" do
  version "0.8.4"
  sha256 "6c05505f1ef6b72a1d79bd600f5a574b9b915f20672a21b7cb3bad963c2e5b4f"

  url "https://storage.googleapis.com/mimestream-releases/Mimestream_#{version}.dmg",
      verified: "storage.googleapis.com/mimestream-releases"
  appcast "https://mimestream.com/appcast.xml"
  name "Mimestream"
  desc "Native email client for Gmail"
  homepage "https://mimestream.com/"

  auto_updates true
  depends_on macos: ">= :catalina"

  app "Mimestream.app"
end
