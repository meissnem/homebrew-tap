cask 'subtools-beta' do
  version '2.0.b4'
  sha256 'c08552684aadd4832356f4987febde1f6d4f33a08ae76348824c39cae1079bb4'

  url "http://www.emmgunn.com/downloads/subtools#{version}.zip"
  name 'SUBtools'
  homepage 'http://www.emmgunn.com/subtools-home/'

  app "subtools#{version}/SUBtools.app"
end
