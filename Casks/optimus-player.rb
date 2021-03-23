cask "optimus-player" do
  version "1.4,12"
  sha256 "6709f0789f1bc189c38c1770da6a410a17063f431268cb808444832820b24941"

  url "https://download.optimusplayer.com/Optimus%20Player%20#{version.before_comma}.dmg"
  name "Optimus Player"
  desc "Audio/Video player"
  homepage "https://www.optimusplayer.com/"

  livecheck do
    url "https://download.optimusplayer.com/appcast.xml"
    strategy :sparkle
  end

  auto_updates true

  app "Optimus Player.app"
end
