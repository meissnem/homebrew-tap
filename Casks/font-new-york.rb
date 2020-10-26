cask 'font-new-york' do
  version '16.0d2e2'
  sha256 '6cf7c864a9e4c556f52cadaff03133d81530895833dee03ddc20889c481eeb0f'

  url 'https://devimages-cdn.apple.com/design/resources/download/NY-Font.dmg'
  name 'New York'
  homepage 'https://developer.apple.com/fonts/'

  pkg 'NY Fonts.pkg'

  uninstall pkgutil: ['^com.apple.pkg.NYFonts$']
end
