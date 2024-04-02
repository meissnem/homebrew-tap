class HcElasticsearch < Formula
  desc "Distributed search & analytics engine"
  homepage "https://www.elastic.co/products/elasticsearch"

  depends_on "openjdk"

  on_macos do
    on_arm do
      url "https://artifacts.elastic.co/downloads/elasticsearch/" \
          "elasticsearch-7.17.19-darwin-aarch64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "73637822579d71ac429414cf0b42d9856926ea176b0d1729f87495cc1645e30d"
    end
    on_intel do
      url "https://artifacts.elastic.co/downloads/elasticsearch/" \
          "elasticsearch-7.17.19-darwin-x86_64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "b474a9576f5d49b56d80610dfda4d3d60fb76382f11d3b37ea56978f1822a9cf"
    end
  end
  on_linux do
    on_arm do
      url "https://artifacts.elastic.co/downloads/elasticsearch/" \
          "elasticsearch-7.17.19-linux-aarch64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "387d7817d722fb275eb59de2c42672108cba25aac48a6786e80c796ea6d3dc11"
    end
    on_intel do
      url "https://artifacts.elastic.co/downloads/elasticsearch/" \
          "elasticsearch-7.17.19-linux-x86_64.tar.gz?tap=elastic/homebrew-tap"
      sha256 "71761ad170d6ce3fda2289e6eb085ce9e5c6b3ac3c4b47287f8a4722c1ebd83a"
    end
  end
  conflicts_with "elasticsearch"

  def cluster_name
    "elasticsearch_#{ENV["USER"]}"
  end

  def install
    # Install everything else into package directory
    libexec.install "bin", "config", "jdk.app", "lib", "modules"

    inreplace libexec/"bin/elasticsearch-env",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"$ES_HOME\"/config; fi",
              "if [ -z \"$ES_PATH_CONF\" ]; then ES_PATH_CONF=\"#{etc}/elasticsearch\"; fi"

    # Set up Elasticsearch for local development:
    inreplace "#{libexec}/config/elasticsearch.yml" do |s|
      # 1. Give the cluster a unique name
      s.gsub!(/#\s*cluster\.name: .*/, "cluster.name: #{cluster_name}")

      # 2. Configure paths
      s.sub!(%r{#\s*path\.data: /path/to.+$}, "path.data: #{var}/lib/elasticsearch/")
      s.sub!(%r{#\s*path\.logs: /path/to.+$}, "path.logs: #{var}/log/elasticsearch/")
    end

    inreplace "#{libexec}/config/jvm.options", %r{logs/gc.log}, "#{var}/log/elasticsearch/gc.log"

    # Move config files into etc
    (etc/"elasticsearch").install Dir[libexec/"config/*"]
    (libexec/"config").rmtree

    Dir.foreach(libexec/"bin") do |f|
      next if f == "." || f == ".." || !File.extname(f).empty?

      bin.install libexec/"bin"/f
    end
    bin.env_script_all_files(libexec/"bin", {})

    darwin_platform = Hardware::CPU.arm? ? "darwin-aarch64" : "darwin-x86_64"

    system "codesign", "-f", "-s", "-", "#{libexec}/modules/x-pack-ml/platform/#{darwin_platform}/controller.app",
"--deep"
    system "find", "#{libexec}/jdk.app/Contents/Home/bin", "-type", "f", "-exec", "codesign", "-f", "-s", "-", "{}",
           ";"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"lib/elasticsearch/#{cluster_name}").mkpath
    (var/"log/elasticsearch").mkpath
    ln_s etc/"elasticsearch", libexec/"config"
    (var/"elasticsearch/plugins").mkpath
    ln_s var/"elasticsearch/plugins", libexec/"plugins"
  end

  def caveats
    <<~EOS
      Data:    #{var}/lib/elasticsearch/#{cluster_name}/
      Logs:    #{var}/log/elasticsearch/#{cluster_name}.log
      Plugins: #{var}/elasticsearch/plugins/
      Config:  #{etc}/elasticsearch/
    EOS
  end

  service do
    run [opt_bin/"elasticsearch"]
    working_dir var
    log_path var/"log/elasticsearch.log"
    error_log_path var/"log/elasticsearch.log"
    require_root false
    environment_variables ES_JAVA_HOME: Formula["openjdk"].opt_prefix
  end

  test do
    require "socket"

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    mkdir testpath/"config"
    cp etc/"elasticsearch/jvm.options", testpath/"config"
    cp etc/"elasticsearch/log4j2.properties", testpath/"config"
    touch testpath/"config/elasticsearch.yml"

    ENV["ES_PATH_CONF"] = testpath/"config"

    system "#{bin}/elasticsearch-plugin", "list"

    pid = testpath/"pid"
    begin
      system "#{bin}/elasticsearch", "-d", "-p", pid, "-Expack.security.enabled=false",
             "-Epath.data=#{testpath}/data", "-Epath.logs=#{testpath}/logs",
             "-Enode.name=test-cli", "-Ehttp.port=#{port}"
      sleep 30
      system "curl", "-XGET", "localhost:#{port}/"
      output = shell_output("curl -s -XGET localhost:#{port}/_cat/nodes")
      assert_match "test-cli", output
    ensure
      Process.kill(9, pid.read.to_i)
    end

    server = TCPServer.new(0)
    port = server.addr[1]
    server.close

    rm testpath/"config/elasticsearch.yml"
    (testpath/"config/elasticsearch.yml").write <<~EOS
      path.data: #{testpath}/data
      path.logs: #{testpath}/logs
      node.name: test-es-path-conf
      http.port: #{port}
    EOS

    pid = testpath/"pid"
    begin
      system "#{bin}/elasticsearch", "-d", "-p", pid, "-Expack.security.enabled=false"
      sleep 30
      system "curl", "-XGET", "localhost:#{port}/"
      output = shell_output("curl -s -XGET localhost:#{port}/_cat/nodes")
      assert_match "test-es-path-conf", output
    ensure
      Process.kill(9, pid.read.to_i)
    end
  end
end
