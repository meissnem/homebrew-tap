class HcProj < Formula
  desc "Cartographic Projections Library"
  homepage "https://proj4.org/"
  url "https://download.osgeo.org/proj/proj-5.2.0.tar.gz"
  sha256 "ef919499ffbc62a4aae2659a55e2b25ff09cccbbe230656ba71c6224056c7e60"

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/hc-proj-5.2.0"
    sha256 arm64_monterey: "f81bd706b4fc945669df40f6736a33ec8fe2a818b210a835cf63cede928c0d12"
    sha256 big_sur:        "dea48265e0ce468890a1254a5fbdd54c278d8cee6658b1a0b68657591079655b"
    sha256 catalina:       "a8f4f8c397f1e8b8188958e3ebefccb4a4455b640c81545e015a8de4ccbe8bc0"
    sha256 monterey:       "00354537e59ab240a9bfd8551bc0fadace39814a396053311c9b71935552996c"
    sha256 x86_64_linux:   "8b8885dd10b16d62e4de030375c62a5ab287925bd6ec41fdd8ea7543e602be39"
  end

  keg_only :versioned_formula

  conflicts_with "blast", because: "both install a `libproj.a` library"
  conflicts_with "proj", becuase: "both want to be `proj`"

  skip_clean :la

  # The datum grid files are required to support datum shifting
  resource "datumgrid" do
    url "https://download.osgeo.org/proj/proj-datumgrid-1.8.zip"
    sha256 "b9838ae7e5f27ee732fb0bfed618f85b36e8bb56d7afb287d506338e9f33861e"
  end

  def install
    (buildpath/"nad").install resource("datumgrid")

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test").write <<~EOS
      45d15n 71d07w Boston, United States
      40d40n 73d58w New York, United States
      48d51n 2d20e Paris, France
      51d30n 7'w London, England
    EOS
    match = <<~EOS
      -4887590.49\t7317961.48 Boston, United States
      -5542524.55\t6982689.05 New York, United States
      171224.94\t5415352.81 Paris, France
      -8101.66\t5707500.23 London, England
    EOS
    assert_equal match,
                 `#{bin}/proj +proj=poly +ellps=clrk66 -r #{testpath}/test`
  end
end
