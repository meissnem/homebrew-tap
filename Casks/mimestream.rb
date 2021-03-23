cask "mimestream" do
  version "0.14.3,134"
  sha256 "eb50f230d4600ee8ae927a6922b77eea2bf686fbca3f0b1e83cee5b4822b4f83"

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
