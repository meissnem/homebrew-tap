cask 'bodo' do
  version '0.3.12'
  sha256 '970148547ecd53f0d646d100109ec36c25f961de0ef0fe20fceda07decc92817'

  url "https://download.getbodo.com/Bodo_#{version}.dmg"
  appcast 'https://download.getbodo.com/appcast.xml'
  name 'Bodo'
  homepage 'https://getbodo.com/'

  auto_updates true

  app 'Bodo.app'
end
