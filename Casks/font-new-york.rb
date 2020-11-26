cask 'font-new-york' do
  version '16.0d2e2'
  sha256 '58058b5dbddb77eec84a0c0b10b41fc544bc7cd50c6cb49874da4197f91afde5'

  url 'https://devimages-cdn.apple.com/design/resources/download/NY-Font.dmg'
  name 'New York'
  homepage 'https://developer.apple.com/fonts/'

  pkg 'NY Fonts.pkg'

  uninstall pkgutil: ['^com.apple.pkg.NYFonts$']
end
