cask "bodo" do
  version "0.5.7,65"
  sha256 "6465653a6ec079e9bd0410af177db9de16203840313c3efdaa90c0de7c29fb95"

  url "https://download.getbodo.com/Bodo_#{version.csv.first}.dmg"
  name "Bodo"
  desc "Better way to use Jira"
  homepage "https://getbodo.com/"

  livecheck do
    url "https://download.getbodo.com/appcast.xml"
    strategy :sparkle
  end

  auto_updates true

  app "Bodo.app"
end
