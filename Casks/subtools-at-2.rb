cask "subtools-at-2" do
  version "2.0.b4"
  sha256 "c08552684aadd4832356f4987febde1f6d4f33a08ae76348824c39cae1079bb4"

  url "https://www.emmgunn.com/downloads/subtools#{version}.zip"
  name "SUBtools"
  desc "Subtitle tool for video files"
  homepage "https://www.emmgunn.com/subtools-home/"

  livecheck do
    url "http://www.emmgunn.com/downloads/"
    regex(/href=.*?subtools(\d[^ %]+?)\.zip"/i)
  end

  app "subtools#{version}/SUBtools.app"
end
