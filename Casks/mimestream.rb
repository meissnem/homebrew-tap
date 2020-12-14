cask "mimestream" do
  version "0.8.1"
  sha256 "a0deaad9420a707cfb9762c973c3142625a08c85f03c5a3c393dfa1ba8c72717"

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
