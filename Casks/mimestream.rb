cask "mimestream" do
  version "0.7.2a"
  sha256 "36775925cb101b182e639fafabad94cdd87d7e68cf471a69758e8f6543244806"

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
