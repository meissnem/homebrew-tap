cask "font-sf-mono" do
  version "16.0d2e1"
  sha256  "fe04fe76d4f3847dc401566c47de14c0d14679d624680671b5d03938bf2ca22f"

  url "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg"
  name "SF Mono"
  desc "Apple's system monospaced font"
  homepage "https://developer.apple.com/fonts/"

  pkg "SF Mono Fonts.pkg"

  uninstall pkgutil: ["^com.apple.pkg.SFMonoFonts$"]
end
