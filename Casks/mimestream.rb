cask "mimestream" do
  version "0.9.2"
  sha256 "4ca07ae72ce411a201af2ad7ed1b963dd321528a53c8a63632d2d20ae86547d7"

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
