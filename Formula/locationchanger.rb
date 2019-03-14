class Locationchanger < Formula
  desc "Change network location based on the name of Wi-Fi network"
  homepage "https://github.com/eprev/locationchanger"
  url "https://github.com/eprev/locationchanger/raw/master/locationchanger.sh"
  version "0.1"
  sha256 "3566ae5d436dfc0a0ecf69616a0501e8e29e5e0f4268907ac084427cb2bda645"

  def install
    inreplace "locationchanger.sh" do |s|
      s.gsub! "sudo -v", ""
      s.gsub! "sudo", ""
      s.gsub! "/usr/local", prefix.to_s
      s.gsub! /LAUNCH_AGENTS_DIR=.*/, "LAUNCH_AGENTS_DIR=#{prefix}"
      s.gsub! /PLIST_NAME=.*/, "PLIST_NAME=#{plist_path}"
      s.gsub! "launchctl load", "#launchctl load"
    end

    bin.mkpath

    system "/bin/bash", "-x", "locationchanger.sh"
  end

  plist_options :startup => true

  test do
    system "false"
  end
end
