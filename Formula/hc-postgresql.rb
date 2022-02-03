class HcPostgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v11.14/postgresql-11.14.tar.bz2"
  sha256 "965c7f4be96fb64f9581852c58c4f05c3812d4ad823c0f3e2bdfe777c162f999"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(11(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/meissnem/homebrew-tap/releases/download/hc-postgresql-11.14"
    sha256 arm64_monterey: "2c3d566b49a5d7219e796ab6d9d624da62bef21de58efc6640067396e9533212"
    sha256 big_sur:        "200b75f4e7c8a47599ef0d93b82a39212d7605fab687a482660718e71dad2e81"
    sha256 catalina:       "ce6e538e65e5b5767f4d8d47a716ba46e79121f01627c693b4d7cde1d0ff522b"
    sha256 monterey:       "08186a41013217d3ff22e37b1e1bf4ba5ce7f6623c96fe1d0b2e5798653a186b"
    sha256 x86_64_linux:   "b362745e3961dc78c7698c3a2a5a4e61be313745fad1108e4e57e1f2e788a40c"
  end

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2023-11-09", because: :unsupported

  depends_on "pkg-config" => :build
  depends_on "icu4c"
  depends_on "openssl@1.1"
  depends_on "readline"

  uses_from_macos "krb5"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "openldap"
  uses_from_macos "perl"
  uses_from_macos "zlib"

  on_linux do
    depends_on "linux-pam"
    depends_on "util-linux"
  end

  conflicts_with "postgresql", because: "both want to be postgresql"

  resource "hc-db-setup.sh" do
    url "https://raw.githubusercontent.com/meissnem/homebrew-tap/11b156084fd2908b70bc07f7b57dbc1670e902fc/Resources/hc-db-setup.sh"
    sha256 "2c77bf52ade30b3291a6f711270b5227121af903078b822d76cd6e54c713f7ff"
  end

  def install
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@1.1"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@1.1"].opt_include} -I#{Formula["readline"].opt_include}"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql
      --libdir=#{HOMEBREW_PREFIX}/lib
      --includedir=#{HOMEBREW_PREFIX}/include
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-thread-safety
      --with-gssapi
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-pam
      --with-perl
      --with-uuid=e2fs
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-tcl
      ]
    end

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if MacOS.sdk_root_needed?

    system "./configure", *args
    system "make"
    system "make", "install-world", "datadir=#{share}/postgresql",
                                    "libdir=#{lib}",
                                    "pkglibdir=#{lib}/postgresql",
                                    "includedir=#{include}",
                                    "pkgincludedir=#{include}/postgresql",
                                    "includedir_server=#{include}/postgresql/server",
                                    "includedir_internal=#{include}/postgresql/internal"

    return unless OS.linux?

    inreplace lib/"postgresql/pgxs/src/Makefile.global",
              "LD = #{HOMEBREW_PREFIX}/Homebrew/Library/Homebrew/shims/linux/super/ld",
              "LD = #{HOMEBREW_PREFIX}/bin/ld"
  end

  def post_install
    (var/"log").mkpath
    postgresql_datadir.mkpath

    # Don't initialize database, it clashes when testing other PostgreSQL versions.
    return if ENV["HOMEBREW_GITHUB_ACTIONS"]

    resource("hc-db-setup.sh").stage do
      system "/bin/sh", "hc-db-setup.sh", bin, postgresql_datadir unless pg_version_exists?
    end
  end

  def postgresql_datadir
    var/"postgres"
  end

  def postgresql_log_path
    var/"log/postgres.log"
  end

  def pg_version_exists?
    (postgresql_datadir/"PG_VERSION").exist?
  end

  def caveats
    <<~EOS
      This formula has created a default database cluster with:
        initdb --username=postgres --locale=en_US.UTF-8 -E UTF-8 #{postgresql_datadir}
      For more details, read:
        https://www.postgresql.org/docs/#{version.major}/app-initdb.html
    EOS
  end

  service do
    run [opt_bin/"postgres", "-D", var/"postgres"]
    keep_alive true
    log_path var/"log/postgres.log"
    error_log_path var/"log/postgres.log"
    working_dir HOMEBREW_PREFIX
  end

  test do
    system "#{bin}/initdb", testpath/"test" unless ENV["HOMEBREW_GITHUB_ACTIONS"]
    assert_equal "#{HOMEBREW_PREFIX}/share/postgresql", shell_output("#{bin}/pg_config --sharedir").chomp
    assert_equal "#{HOMEBREW_PREFIX}/lib", shell_output("#{bin}/pg_config --libdir").chomp
    assert_equal "#{HOMEBREW_PREFIX}/lib/postgresql", shell_output("#{bin}/pg_config --pkglibdir").chomp
  end
end
