cask 'optimus-player' do
  version '1.1'
  sha256 '0484e7b3bfccf438328679cadde606763c491fc12627fa2d86e6b392f493fa32'

  url "https://download.optimusplayer.com/Optimus%20Player%20#{version}.dmg"
  name 'Optimus Player'
  homepage 'https://www.optimusplayer.com/'

  app 'Optimus Player.app'
end
