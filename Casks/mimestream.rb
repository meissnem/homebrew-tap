cask "mimestream" do
  version "0.20.3,148"
  sha256 "f89d299c2144a51a216dd4069ac2260d9c540ed848c779c931691b9b72bfc112"

  url "https://storage.googleapis.com/mimestream-releases/Mimestream_#{version.before_comma}.dmg",
      verified: "storage.googleapis.com/mimestream-releases"
  name "Mimestream"
  desc "Native email client for Gmail"
  homepage "https://mimestream.com/"

  livecheck do
    url "https://mimestream.com/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  depends_on macos: ">= :catalina"

  app "Mimestream.app"
end
