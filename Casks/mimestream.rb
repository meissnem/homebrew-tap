cask "mimestream" do
  version "0.8.2"
  sha256 "3da2a7f671645a2201476678180f4ed7558b008ede7351b3fb67eda55df0d4e7"

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
