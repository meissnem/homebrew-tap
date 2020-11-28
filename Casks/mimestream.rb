cask "mimestream" do
  version "0.7.7"
  sha256 "ba5785ab84f885ac7e0edd16f04b25e32d3faf1fdbdc1dd1987141a3beb29a09"

  # storage.googleapis.com was verified as official when first introduced to the cask
  url "https://storage.googleapis.com/mimestream-releases/Mimestream_#{version}.dmg"
  appcast "https://mimestream.com/appcast.xml"
  name "Mimestream"
  desc "Native email client for Gmail"
  homepage "https://mimestream.com/"

  auto_updates true
  depends_on macos: ">= :catalina"

  app "Mimestream.app"
end
