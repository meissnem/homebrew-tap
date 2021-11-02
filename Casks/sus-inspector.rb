cask "sus-inspector" do
  version "2.0b1"
  sha256 "344d43ba3e77320f9a9d5a5b9383d5c28ada63565f0c375b4dda5f2495d92b97"

  url "https://github.com/hjuutilainen/sus-inspector/releases/download/v#{version}/SUS-Inspector-#{version}.dmg"
  name "SUS Inspector"
  desc "Inspect Apple software updates"
  homepage "https://github.com/hjuutilainen/sus-inspector/"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # livecheck do
  #   url "https://www.xquartz.org/releases/sparkle/release.xml"
  #   strategy :sparkle do |item|
  #     item.short_version.delete_prefix("XQuartz-")
  #   end
  # end

  app "SUS Inspector.app"

  zap trash: ["~/Library/Application Support/SUS Inspector/*"],
      rmdir: ["~/Library/Application Support/SUS Inspector"]
end
