cask "twitterrific" do
  version "5.4.5+151"
  sha256 "ca03e8b989a16cfb88cb86c776c42a7c88110ba1c9db5adf3b55fe15b85e3e57"

  # downloads.iconfactory.com/phoenix/Twitterrific- was verified as official when first introduced to the cask
  url "https://downloads.iconfactory.com/phoenix/Twitterrific-#{version}.zip"
  appcast "https://iconfactory.com/appcasts/Phoenix/appcast.xml"
  name "Twitterrific"
  desc "Twitter client"
  homepage "https://twitterrific.com/mac"

  auto_updates true

  app "Phoenix.app"
end
