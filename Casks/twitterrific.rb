cask 'twitterrific' do
  version "5.4.3"
  sha256 'ff292fadea9fb820bcb2c6117b098dbb1513a23ac884a9231f4d2f89ea6a5a8c'

  # https://downloads.iconfactory.com/phoenix was verified as official when first introduced to the cask
  url "https://downloads.iconfactory.com/phoenix/Twitterrific-5.4.3+134.zip"
  appcast 'https://iconfactory.com/appcasts/Phoenix/appcast.xml'
  name 'Twitterrific'
  homepage 'http://twitterrific.com/mac'

  auto_updates true

  app 'Phoenix.app'
end
