class Locationchanger < Formula
  desc "Change network location based on the name of Wi-Fi network"
  homepage "https://github.com/eprev/locationchanger"
  url "https://github.com/eprev/locationchanger/raw/master/locationchanger.sh"
  version "0.1"
  sha256 "3566ae5d436dfc0a0ecf69616a0501e8e29e5e0f4268907ac084427cb2bda645"

  bottle do
    root_url "https://github.com/meissnem/homebrew-meissnem/releases/download"
    cellar :any_skip_relocation
    sha256 "119d339200106da90076b16d45e1431a61154197c6135c17dec618a553a8fb8c" => :big_sur
  end

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

  plist_options startup: true

  test do
    system "false"
  end
end
