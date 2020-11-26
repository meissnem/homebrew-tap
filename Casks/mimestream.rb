cask "mimestream" do
  version "0.7.5"
  sha256 "d8a6ea5fff707866a78915fac96ae5eaba17ccc3d8fbd7bd6ea15e7c46b27280"

  # storage.googleapis.com was verified as official when first introduced to the cask
  url "https://storage.googleapis.com/mimestream-releases/Mimestream_#{version}.dmg"
  appcast "https://storage.googleapis.com/mimestream-releases/appcast.xml"
  name "Mimestream"
  desc "Native email client for Gmail"
  homepage "https://mimestream.com/"

  depends_on macos: ">= :catalina"

  auto_updates true

  app "Mimestream.app"
end
