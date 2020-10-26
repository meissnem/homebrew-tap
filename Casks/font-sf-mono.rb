cask 'font-sf-mono' do
  version '16.0d2e1'
  sha256 :no_check

  url 'https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg'
  name 'SF Mono'
  homepage 'https://developer.apple.com/fonts/'

  pkg 'SF Mono Fonts.pkg'

  uninstall pkgutil: ['^com.apple.pkg.SFMonoFonts$']
end
