cask "font-sf-mono" do
  version :latest
  sha256  :no_check

  url "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg"
  name "SF Mono"
  desc "Apple's system monospaced font"
  homepage "https://developer.apple.com/fonts/"

  pkg "SF Mono Fonts.pkg"

  uninstall pkgutil: ["^com.apple.pkg.SFMonoFonts$"]
end
