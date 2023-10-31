class HcKibana < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  on_macos do
    on_arm do
      url "https://artifacts.elastic.co/downloads/kibana/kibana-7.17.14-darwin-aarch64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "cff5ded06eaa1b59c53267c2e9a2cf30860c8442b76c6c2c69478c178bd56529"
    end
    on_intel do
      url "https://artifacts.elastic.co/downloads/kibana/kibana-7.17.14-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "ac2b5a639ad83431db25e4161f811111d45db052eb845091e18f847016a34a55"
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
    bin.env_script_all_files(libexec/"bin", { "KIBANA_PATH_CONF" => etc/"kibana", "DATA_PATH" => var/"lib/kibana/data" })

    cd libexec do
      packaged_config = IO.read "config/kibana.yml"
      IO.write "config/kibana.yml", "path.data: #{var}/lib/kibana/data\n" + packaged_config
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
      rm_rf "data"
    end
  end

  def post_install
    (var/"lib/kibana/data").mkpath
    (prefix/"plugins").mkdir
  end

  def caveats; <<~EOS
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
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end
