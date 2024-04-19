class HcProj < Formula
  desc "Cartographic Projections Library"
  homepage "https://proj4.org/"
  url "https://download.osgeo.org/proj/proj-5.2.0.tar.gz"
  sha256 "ef919499ffbc62a4aae2659a55e2b25ff09cccbbe230656ba71c6224056c7e60"

  livecheck do
    url "https://download.osgeo.org/proj/"
    regex(/href=.*?proj[\._-](5[\d\.]+)\.t/i)
  end

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/hc-proj-5.2.0"
    rebuild 1
    sha256 arm64_sonoma: "1f0090cc2496203809440c3e28bd228fb39f9d62b275c5061f5a0989c8e14041"
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
