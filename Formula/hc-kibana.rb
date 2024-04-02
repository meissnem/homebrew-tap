class HcKibana < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  depends_on :macos

  on_macos do
    on_arm do
      url "https://artifacts.elastic.co/downloads/kibana/" \
          "kibana-7.17.19-darwin-aarch64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "46080947f11d0f36fe56eff7fe13c3f607e01bab556e8112e906b4a6a0292014"
    end
    on_intel do
      url "https://artifacts.elastic.co/downloads/kibana/kibana-7.17.19-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "61635b572d59e59d7cea375fed97eb2fc461ac334e45453f6ffaec2406666791"
    end
  end

  on_linux do
    on_arm do
      url "https://artifacts.elastic.co/downloads/kibana/kibana-7.17.19-linux-aarch64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "929451dc148d62eee5f638748c0e0f51fe619e9e92c194164f383a158ba4e96c"
    end
    on_intel do
      url "https://artifacts.elastic.co/downloads/kibana/kibana-7.17.19-linux-x86_64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "c77d837a219502d89d41e7f09c4ede29c110374402082d3f6b2b1769a244167a"
    end
  end

  def install
    libexec.install(
      "bin",
      "config",
      "data",
      "node",
      "node_modules",
      "package.json",
      "plugins",
      "src",
      "x-pack",
    )

    Pathname.glob(libexec/"bin/*") do |f|
      next if f.directory?

      bin.install libexec/"bin"/f
    end
    bin.env_script_all_files(libexec/"bin",
{ "KIBANA_PATH_CONF" => etc/"kibana", "DATA_PATH" => var/"lib/kibana/data" })

    cd libexec do
      packaged_config = File.read "config/kibana.yml"
      File.write "config/kibana.yml", "path.data: #{var}/lib/kibana/data\n" + packaged_config
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
      rm_rf "data"
    end
  end

  def post_install
    (var/"lib/kibana/data").mkpath
    (prefix/"plugins").mkdir
  end

  def caveats
    <<~EOS
      Config: #{etc}/kibana/
      If you wish to preserve your plugins upon upgrade, make a copy of
      #{opt_prefix}/plugins before upgrading, and copy it into the
      new keg location after upgrading.
    EOS
  end

  service do
    run [opt_bin/"kibana"]
    working_dir var
    log_path var/"log/kibana.log"
    error_log_path var/"log/kibana.log"
    require_root false
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match(/#{version}/, shell_output("#{bin}/kibana -V"))
  end
end
