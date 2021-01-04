cask "mimestream" do
  version "0.8.5"
  sha256 "ba39ad1b3af8361a42befe5d512af19efb3be72326d0cf5d463bcc3ecaf9d2a7"

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
