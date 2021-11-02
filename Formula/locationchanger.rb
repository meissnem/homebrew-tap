class Locationchanger < Formula
  desc "Change network location based on the name of Wi-Fi network"
  homepage "https://github.com/eprev/locationchanger"
  url "https://github.com/eprev/locationchanger/raw/master/locationchanger.sh"
  version "0.1-1"
  sha256 "1107e5b701ff2f76e482787f6e7e714db2aad0328b3902bb84d8c61d94bb26e6"

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/locationchanger-0.1-1"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "5d0ce60cd11035a117482dbcbb6f39433498f6507ea91656bef9b8dc5afb24bc"
  end

  depends_on :macos

  def install
    inreplace "locationchanger.sh" do |s|
      s.gsub! "sudo -v", ""
      s.gsub! "sudo", ""
      s.gsub! "/usr/local", prefix.to_s
      s.gsub!(/LAUNCH_AGENTS_DIR=.*/, "LAUNCH_AGENTS_DIR=#{prefix}")
      s.gsub!(/PLIST_NAME=.*/, "PLIST_NAME=#{prefix}/#{plist_name}.plist")
      s.gsub! "launchctl load", "#launchctl load"
    end

    bin.mkpath

    system "/bin/bash", "-x", "locationchanger.sh"
  end

  plist_options startup: true

  test do
    system "true"
  end
end
