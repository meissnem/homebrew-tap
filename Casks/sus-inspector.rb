cask "sus-inspector" do
  version "2.1"
  sha256 "660c7d5409841fe3cfb18cca8e119b51f8e1defb622dd1ea239c5a78443b82b7"

  url "https://github.com/hjuutilainen/sus-inspector/releases/download/v#{version}/SUS-Inspector-#{version}.dmg"
  name "SUS Inspector"
  desc "Inspect Apple software updates"
  homepage "https://github.com/hjuutilainen/sus-inspector/"

  livecheck do
    url :stable
    strategy :github_latest
  end

  app "SUS Inspector.app"

  zap trash: ["~/Library/Application Support/SUS Inspector/*"],
      rmdir: ["~/Library/Application Support/SUS Inspector"]
end
