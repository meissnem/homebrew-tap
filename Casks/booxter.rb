cask "booxter" do
  version "2.8.2"
  sha256 "e54e5197ea92d0e7027d6002b755de35c7510076e74ab880ace16a5549e277d2"

  url "https://www.deepprose.com/download/Booxter_#{version}.dmg"
  name "Booxter"
  desc "#{name} helps you track your collections of books and other media"
  homepage "https://www.deepprose.com/"

  livecheck do
    url "https://www.deepprose.com/updates/booxter.xml"
    strategy :sparkle, &:short_version
  end

  app "Booxter.app"
end
