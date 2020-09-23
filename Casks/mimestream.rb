cask "mimestream" do
  version "0.6.22"
  sha256 "658792af9093af6b45c928605887c66292994801cd31c6b0457a69b26552d641"

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
