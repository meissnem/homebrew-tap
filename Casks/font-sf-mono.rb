cask 'font-sf-mono' do
  version '16.0d2e1'
  sha256  'd91ed5d03a249b515dd1ba9aba7127dcd85bd1c7d2a3a7687531524b6d9a6a6d'

  url 'https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg'
  name 'SF Mono'
  homepage 'https://developer.apple.com/fonts/'

  pkg 'SF Mono Fonts.pkg'

  uninstall pkgutil: ['^com.apple.pkg.SFMonoFonts$']
end
