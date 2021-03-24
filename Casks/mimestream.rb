cask "mimestream" do
  version "0.14.4,135"
  sha256 "bd73fe6225d52bee59bfb50936c59432f2e1ace80e4860bb9059a84556742218"

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
