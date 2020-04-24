cask 'bodo' do
  version '0.5.2'
  sha256 '561e13d57caa8aff60fbd020607e22908ba08594135f7501655a55d74f06eaea'

  url "https://download.getbodo.com/Bodo_#{version}.dmg"
  appcast 'https://download.getbodo.com/appcast.xml'
  name 'Bodo'
  homepage 'https://getbodo.com/'

  auto_updates true

  app 'Bodo.app'
end
