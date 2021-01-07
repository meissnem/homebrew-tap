cask "mimestream" do
  version "0.8.6"
  sha256 "eea5fe7a806db10ad3e7ea637959b8acf06a9256fdfe889ad8a9aed7aa849b36"

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
