class PythonAT36 < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tar.xz"
  sha256 "6e28d7cdd6dd513dd190e49bca3972e20fcf455090ccf2ef3f1a227614135d91"
  license "Python-2.0"

  livecheck do
    url "https://www.python.org/ftp/python/"
    regex(%r{href=.*?v?(3\.6(?:\.\d+)*)/?["' >]}i)
  end

  # setuptools remembers the build flags python is built with and uses them to
  # build packages later. Xcode-only systems need different flags.
  pour_bottle? do
    on_macos do
      reason <<~EOS
        The bottle needs the Apple Command Line Tools to be installed.
          You can install them, if desired, with:
            xcode-select --install
      EOS
      satisfy { MacOS::CLT.installed? }
    end
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on arch: :x86_64
  depends_on "gdbm"
  depends_on "mpdecimal"
  depends_on "openssl@1.1"
  depends_on "readline"
  depends_on "sqlite"
  depends_on "xz"

  uses_from_macos "bzip2"
  uses_from_macos "libffi"
  uses_from_macos "ncurses"
  uses_from_macos "xz"
  uses_from_macos "zlib"

  skip_clean "bin/pip3", "bin/pip-3.4", "bin/pip-3.5", "bin/pip-3.7", "bin/pip-3.8", "bin/pip-3.9"
  skip_clean "bin/easy_install3", "bin/easy_install-3.4", "bin/easy_install-3.5",
    "bin/easy_install-3.7", "bin/easy_install-3.8", "bin/easy_install-3.9"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/12/68/95515eaff788370246dac534830ea9ccb0758e921ac9e9041996026ecaf2/setuptools-53.0.0.tar.gz"
    sha256 "1b18ef17d74ba97ac9c0e4b4265f123f07a8ae85d9cd093949fa056d3eeeead5"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/b7/2d/ad02de84a4c9fd3b1958dc9fb72764de1aa2605a9d7e943837be6ad82337/pip-21.0.1.tar.gz"
    sha256 "99bbde183ec5ec037318e774b0d8ae0a64352fe53b2c7fd630be1d07e94f41e5"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/75/28/521c6dc7fef23a68368efefdcd682f5b3d1d58c2b90b06dc1d0b805b51ae/wheel-0.34.2.tar.gz"
    sha256 "8788e9155fe14f54164c1b9eb0a319d98ef02c160725587ad60f14ddc57b6f96"
  end

  resource "importlib-metadata" do
    url "https://files.pythonhosted.org/packages/0c/89/412afa5f0018dccf637c2d25b9d6a41623cd22beef6797c0d67a2082ccfe/importlib_metadata-3.4.0.tar.gz"
    sha256 "fa5daa4477a7414ae34e95942e4dd07f62adf589143c875c133c1e53c4eff38d"
  end

  resource "zipp" do
    url "https://files.pythonhosted.org/packages/ce/b0/757db659e8b91cb3ea47d90350d7735817fe1df36086afc77c1c4610d559/zipp-3.4.0.tar.gz"
    sha256 "ed5eee1974372595f9e416cc7bbeeb12335201d8081ca8a0743c954d4446e5cb"
  end

  # enable --with-openssl. Back-ported from 3.7
  patch :DATA

  # Patch for MACOSX_DEPLOYMENT_TARGET on Big Sur. Upstream currently does
  # not have plans to backport the fix to 3.6, so we're maintaining this patch
  # ourselves.
  # https://bugs.python.org/issue42504
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/05a27807/python/3.7.9.patch"
    sha256 "486188ac1a4af4565de5ad54949939bb69bffc006297e8eac9339f19d7d7492b"
  end

  # Link against libmpdec.so.3, update for mpdecimal.h symbol cleanup.
  patch do
    url "https://www.bytereef.org/contrib/decimal-3.7.diff"
    sha256 "aa9a3002420079a7d2c6033d80b49038d490984a9ddb3d1195bb48ca7fb4a1f0"
  end

  def lib_cellar
    on_macos do
      return prefix/"Frameworks/Python.framework/Versions/#{version.major_minor}/lib/python#{version.major_minor}"
    end
    on_linux do
      return prefix/"lib/python#{version.major_minor}"
    end
  end

  def site_packages_cellar
    lib_cellar/"site-packages"
  end

  # The HOMEBREW_PREFIX location of site-packages.
  def site_packages
    HOMEBREW_PREFIX/"lib/python#{version.major_minor}/site-packages"
  end

  def install
    # Unset these so that installing pip and setuptools puts them where we want
    # and not into some other Python the user has installed.
    ENV["PYTHONHOME"] = nil
    ENV["PYTHONPATH"] = nil

    # Override the auto-detection in setup.py, which assumes a universal build.
    ENV["PYTHON_DECIMAL_WITH_MACHINE"] = "x64" if OS.mac?

    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
      --enable-loadable-sqlite-extensions
      --without-ensurepip
      --with-openssl=#{Formula["openssl@1.1"].opt_prefix}
      --with-system-libmpdec
    ]

    args << "--without-gcc" if ENV.compiler == :clang

    if OS.mac?
      args << "--enable-framework=#{frameworks}"
      args << "--with-dtrace"
    end

    if OS.linux?
      args << "--enable-shared"

      # Required for the _ctypes module
      # see https://github.com/Linuxbrew/homebrew-core/pull/1007#issuecomment-252421573
      args << "--with-system-ffi"
    end

    cflags   = []
    ldflags  = []
    cppflags = []

    if MacOS.sdk_path_if_needed
      # Help Python's build system (setuptools/pip) to build things on SDK-based systems
      # The setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
      cflags  << "-isysroot #{MacOS.sdk_path}"
      ldflags << "-isysroot #{MacOS.sdk_path}"
      # For the Xlib.h, Python needs this header dir with the system Tk
      # Yep, this needs the absolute path where zlib needed a path relative
      # to the SDK.
      cflags << "-isystem #{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"
    end
    # Avoid linking to libgcc https://mail.python.org/pipermail/python-dev/2012-February/116205.html
    args << "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"

    # Python's setup.py parses CPPFLAGS and LDFLAGS to learn search
    # paths for the dependencies of the compiled extension modules.
    # See Linuxbrew/linuxbrew#420, Linuxbrew/linuxbrew#460, and Linuxbrew/linuxbrew#875
    if OS.linux?
      cppflags << ENV.cppflags << " -I#{HOMEBREW_PREFIX}/include"
      ldflags << ENV.ldflags << " -L#{HOMEBREW_PREFIX}/lib"
    end

    # We want our readline! This is just to outsmart the detection code,
    # superenv makes cc always find includes/libs!
    inreplace "setup.py",
      "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')",
      "do_readline = '#{Formula["readline"].opt_lib}/#{shared_library("libhistory")}'"

    inreplace "setup.py" do |s|
      s.gsub! "sqlite_setup_debug = False", "sqlite_setup_debug = True"
      s.gsub! "for d_ in inc_dirs + sqlite_inc_paths:",
              "for d_ in ['#{Formula["sqlite"].opt_include}']:"
    end

    # Allow python modules to use ctypes.find_library to find homebrew's stuff
    # even if homebrew is not a /usr/local/lib. Try this with:
    # `brew install enchant && pip install pyenchant`
    inreplace "./Lib/ctypes/macholib/dyld.py" do |f|
      f.gsub! "DEFAULT_LIBRARY_FALLBACK = [", "DEFAULT_LIBRARY_FALLBACK = [ '#{HOMEBREW_PREFIX}/lib',"
      f.gsub! "DEFAULT_FRAMEWORK_FALLBACK = [", "DEFAULT_FRAMEWORK_FALLBACK = [ '#{HOMEBREW_PREFIX}/Frameworks',"
    end

    args << "CFLAGS=#{cflags.join(" ")}" unless cflags.empty?
    args << "LDFLAGS=#{ldflags.join(" ")}" unless ldflags.empty?
    args << "CPPFLAGS=#{cppflags.join(" ")}" unless cppflags.empty?

    system "./configure", *args
    system "make"

    ENV.deparallelize do
      # Tell Python not to install into /Applications (default for framework builds)
      system "make", "install", "PYTHONAPPSDIR=#{prefix}"
      system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{pkgshare}" if OS.mac?
    end

    # Any .app get a " 3" attached, so it does not conflict with python 2.x.
    Dir.glob("#{prefix}/*.app") { |app| mv app, app.sub(/\.app$/, " 3.app") }

    if OS.mac?
      # Prevent third-party packages from building against fragile Cellar paths
      inreplace Dir[lib_cellar/"**/_sysconfigdata_m_darwin_darwin.py",
                    lib_cellar/"config*/Makefile",
                    frameworks/"Python.framework/Versions/3*/lib/pkgconfig/python-3.?.pc"],
                prefix, opt_prefix

      # Help third-party packages find the Python framework
      inreplace Dir[lib_cellar/"config*/Makefile"],
                /^LINKFORSHARED=(.*)PYTHONFRAMEWORKDIR(.*)/,
                "LINKFORSHARED=\\1PYTHONFRAMEWORKINSTALLDIR\\2"

      # Fix for https://github.com/Homebrew/homebrew-core/issues/21212
      inreplace Dir[lib_cellar/"**/_sysconfigdata_m_darwin_darwin.py"],
                %r{('LINKFORSHARED': .*?)'(Python.framework/Versions/3.\d+/Python)'}m,
                "\\1'#{opt_prefix}/Frameworks/\\2'"
    end

    if OS.linux?
      # Prevent third-party packages from building against fragile Cellar paths
      inreplace Dir[lib_cellar/"**/_sysconfigdata_m_linux_x86_64-*.py",
                    lib_cellar/"config*/Makefile",
                    lib/"pkgconfig/python-3.?.pc"],
                prefix, opt_prefix
    end

    # Symlink the pkgconfig files into HOMEBREW_PREFIX so they're accessible.
    (lib/"pkgconfig").install_symlink Dir["#{frameworks}/Python.framework/Versions/#{version.major_minor}/lib/pkgconfig/*"]

    # Remove the site-packages that Python created in its Cellar.
    site_packages_cellar.rmtree

    %w[setuptools pip wheel importlib-metadata zipp].each do |r|
      (libexec/r).install resource(r)
    end

    # Remove wheel test data.
    # It's for people editing wheel and contains binaries which fail `brew linkage`.
    rm libexec/"wheel/tox.ini"
    rm_r libexec/"wheel/tests"

    # Install unversioned symlinks in libexec/bin.
    {
      "idle"          => "idle3",
      "pydoc"         => "pydoc3",
      "python"        => "python3",
      "python-config" => "python3-config",
    }.each do |unversioned_name, versioned_name|
      (libexec/"bin").install_symlink (bin/versioned_name).realpath => unversioned_name
    end
  end

  def post_install
    ENV.delete "PYTHONPATH"

    # Fix up the site-packages so that user-installed Python software survives
    # minor updates, such as going from 3.3.2 to 3.3.3:

    # Create a site-packages in HOMEBREW_PREFIX/lib/python#{version.major_minor}/site-packages
    site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    site_packages_cellar.unlink if site_packages_cellar.exist?
    site_packages_cellar.parent.install_symlink site_packages

    # Write our sitecustomize.py
    rm_rf Dir["#{site_packages}/sitecustomize.py[co]"]
    (site_packages/"sitecustomize.py").atomic_write(sitecustomize)

    # Remove old setuptools installations that may still fly around and be
    # listed in the easy_install.pth. This can break setuptools build with
    # zipimport.ZipImportError: bad local file header
    # setuptools-0.9.8-py3.3.egg
    rm_rf Dir["#{site_packages}/setuptools*"]
    rm_rf Dir["#{site_packages}/distribute*"]
    rm_rf Dir["#{site_packages}/pip[-_.][0-9]*", "#{site_packages}/pip"]

    %w[setuptools pip wheel importlib-metadata zipp].each do |pkg|
      (libexec/pkg).cd do
        system bin/"python3", "-s", "setup.py", "--no-user-cfg", "install",
               "--force", "--verbose", "--install-scripts=#{bin}",
               "--install-lib=#{site_packages}",
               "--single-version-externally-managed",
               "--record=installed.txt"
      end
    end

    rm_rf [bin/"pip", bin/"easy_install"]
    mv bin/"wheel", bin/"wheel3"

    # Install unversioned symlinks in libexec/bin.
    {
      "pip"   => "pip3",
      "wheel" => "wheel3",
    }.each do |unversioned_name, versioned_name|
      (libexec/"bin").install_symlink (bin/versioned_name).realpath => unversioned_name
    end

    # Help distutils find brewed stuff when building extensions
    include_dirs = [HOMEBREW_PREFIX/"include", Formula["openssl@1.1"].opt_include,
                    Formula["sqlite"].opt_include]
    library_dirs = [HOMEBREW_PREFIX/"lib", Formula["openssl@1.1"].opt_lib,
                    Formula["sqlite"].opt_lib]

    cfg = lib_cellar/"distutils/distutils.cfg"

    cfg.atomic_write <<~EOS
      [install]
      prefix=#{HOMEBREW_PREFIX}

      [build_ext]
      include_dirs=#{include_dirs.join ":"}
      library_dirs=#{library_dirs.join ":"}
    EOS
  end

  def sitecustomize
    <<~EOS
      # This file is created by Homebrew and is executed on each python startup.
      # Don't print from here, or else python command line scripts may fail!
      # <https://docs.brew.sh/Homebrew-and-Python>
      import re
      import os
      import sys

      if sys.version_info[0] != 3:
          # This can only happen if the user has set the PYTHONPATH for 3.x and run Python 2.x or vice versa.
          # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
          # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
          # built only for a specific version of Python and will fail with cryptic error messages.
          # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
          exit('Your PYTHONPATH points to a site-packages dir for Python 3.x but you are running Python ' +
               str(sys.version_info[0]) + '.x!\\n     PYTHONPATH is currently: "' + str(os.environ['PYTHONPATH']) + '"\\n' +
               '     You should `unset PYTHONPATH` to fix this.')

      # Only do this for a brewed python:
      if os.path.realpath(sys.executable).startswith('#{rack}'):
          # Shuffle /Library site-packages to the end of sys.path
          library_site = '/Library/Python/#{version.major_minor}/site-packages'
          library_packages = [p for p in sys.path if p.startswith(library_site)]
          sys.path = [p for p in sys.path if not p.startswith(library_site)]
          # .pth files have already been processed so don't use addsitedir
          sys.path.extend(library_packages)

          # the Cellar site-packages is a symlink to the HOMEBREW_PREFIX
          # site_packages; prefer the shorter paths
          long_prefix = re.compile(r'#{rack}/[0-9\._abrc]+/Frameworks/Python\.framework/Versions/#{version.major_minor}/lib/python#{version.major_minor}/site-packages')
          sys.path = [long_prefix.sub('#{site_packages}', p) for p in sys.path]

          # Set the sys.executable to use the opt_prefix. Only do this if PYTHONEXECUTABLE is not
          # explicitly set and we are not in a virtualenv:
          if 'PYTHONEXECUTABLE' not in os.environ and sys.prefix == sys.base_prefix:
              sys.executable = '#{opt_bin}/python#{version.major_minor}'
    EOS
  end

  def caveats
    <<~EOS
      Python has been installed as
        #{opt_bin}/python3

      Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
      `python3`, `python3-config`, `pip3` etc., respectively, have been installed into
        #{opt_libexec}/bin

      You can install Python packages with
        #{opt_bin}/pip3 install <package>
      They will install into the site-package directory
        #{HOMEBREW_PREFIX/"lib/python#{version.major_minor}/site-packages"}

      See: https://docs.brew.sh/Homebrew-and-Python
    EOS
  end

  test do
    # Check if sqlite is ok, because we build with --enable-loadable-sqlite-extensions
    # and it can occur that building sqlite silently fails if OSX's sqlite is used.
    system "#{bin}/python#{version.major_minor}", "-c", "import sqlite3"
    # Check if some other modules import. Then the linked libs are working.

    on_macos do
      # Temporary failure on macOS 11.1 due to https://bugs.python.org/issue42480
      # Reenable unconditionnaly once Apple fixes the Tcl/Tk issue
      system "#{bin}/python#{version.major_minor}", "-c", "import tkinter; root = tkinter.Tk()" if MacOS.full_version < "11.1"
    end

    system "#{bin}/python#{version.major_minor}", "-c", "import _decimal"
    system "#{bin}/python#{version.major_minor}", "-c", "import _gdbm"
    system "#{bin}/python#{version.major_minor}", "-c", "import zlib"
    system bin/"pip3", "list", "--format=columns"
  end
end

__END__
commit ff5be6e8100276647e0077e80869fc022d1bb53f
Author: Christian Heimes <christian@python.org>
Date:   Sat Jan 20 13:19:21 2018 +0100

    bpo-32598: Use autoconf to detect usable OpenSSL (#5242)
    
    Add https://www.gnu.org/software/autoconf-archive/ax_check_openssl.html
    to auto-detect compiler flags, linker flags and libraries to compile
    OpenSSL extensions. The M4 macro uses pkg-config and falls back to
    manual detection.
    
    Add autoconf magic to detect usable X509_VERIFY_PARAM_set1_host()
    and related functions.
    
    Refactor setup.py to use new config vars to compile _ssl and _hashlib
    modules.
    
    Signed-off-by: Christian Heimes <christian@python.org>

diff --git a/Makefile.pre.in b/Makefile.pre.in
index 994e8611e1..d151267173 100644
--- a/Makefile.pre.in
+++ b/Makefile.pre.in
@@ -181,6 +181,11 @@ RUNSHARED=       @RUNSHARED@
 # ensurepip options
 ENSUREPIP=      @ENSUREPIP@
 
+# OpenSSL options for setup.py so sysconfig can pick up AC_SUBST() vars.
+OPENSSL_INCLUDES=@OPENSSL_INCLUDES@
+OPENSSL_LIBS=@OPENSSL_LIBS@
+OPENSSL_LDFLAGS=@OPENSSL_LDFLAGS@
+
 # Modes for directories, executables and data files created by the
 # install process.  Default to user-only-writable for all file types.
 DIRMODE=	755
diff --git a/Misc/NEWS.d/next/Build/2018-01-19-14-50-19.bpo-32598.hP7bMV.rst b/Misc/NEWS.d/next/Build/2018-01-19-14-50-19.bpo-32598.hP7bMV.rst
new file mode 100644
index 0000000000..4b05e73fee
--- /dev/null
+++ b/Misc/NEWS.d/next/Build/2018-01-19-14-50-19.bpo-32598.hP7bMV.rst
@@ -0,0 +1,3 @@
+Use autoconf to detect OpenSSL libs, headers and supported features. The
+ax_check_openssl M4 macro uses pkg-config to locate OpenSSL and falls back
+to manual search.
diff --git a/Modules/_ssl.c b/Modules/_ssl.c
index 380dd1b72d..c5eec7eded 100644
--- a/Modules/_ssl.c
+++ b/Modules/_ssl.c
@@ -64,6 +64,13 @@ static PySocketModule_APIObject PySocketModule;
 #include "openssl/rand.h"
 #include "openssl/bio.h"
 
+/* Set HAVE_X509_VERIFY_PARAM_SET1_HOST for non-autoconf builds */
+#ifndef HAVE_X509_VERIFY_PARAM_SET1_HOST
+#  if !defined(LIBRESSL_VERSION_NUMBER) && OPENSSL_VERSION_NUMBER > 0x1000200fL
+#    define HAVE_X509_VERIFY_PARAM_SET1_HOST
+#  endif
+#endif
+
 /* SSL error object */
 static PyObject *PySSLErrorObject;
 static PyObject *PySSLCertVerificationErrorObject;
diff --git a/aclocal.m4 b/aclocal.m4
index 61b2539d2e..0969496291 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -12,9 +12,9 @@
 # PARTICULAR PURPOSE.
 
 m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
-dnl pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
-dnl serial 11 (pkg-config-0.29)
-dnl
+# pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
+# serial 11 (pkg-config-0.29.1)
+
 dnl Copyright © 2004 Scott James Remnant <scott@netsplit.com>.
 dnl Copyright © 2012-2015 Dan Nicholson <dbn.lists@gmail.com>
 dnl
@@ -55,7 +55,7 @@ dnl
 dnl See the "Since" comment for each macro you use to see what version
 dnl of the macros you require.
 m4_defun([PKG_PREREQ],
-[m4_define([PKG_MACROS_VERSION], [0.29])
+[m4_define([PKG_MACROS_VERSION], [0.29.1])
 m4_if(m4_version_compare(PKG_MACROS_VERSION, [$1]), -1,
     [m4_fatal([pkg.m4 version $1 or higher is required but ]PKG_MACROS_VERSION[ found])])
 ])dnl PKG_PREREQ
@@ -288,3 +288,72 @@ AS_VAR_COPY([$1], [pkg_cv_][$1])
 AS_VAR_IF([$1], [""], [$5], [$4])dnl
 ])dnl PKG_CHECK_VAR
 
+dnl PKG_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND],
+dnl   [DESCRIPTION], [DEFAULT])
+dnl ------------------------------------------
+dnl
+dnl Prepare a "--with-" configure option using the lowercase
+dnl [VARIABLE-PREFIX] name, merging the behaviour of AC_ARG_WITH and
+dnl PKG_CHECK_MODULES in a single macro.
+AC_DEFUN([PKG_WITH_MODULES],
+[
+m4_pushdef([with_arg], m4_tolower([$1]))
+
+m4_pushdef([description],
+           [m4_default([$5], [build with ]with_arg[ support])])
+
+m4_pushdef([def_arg], [m4_default([$6], [auto])])
+m4_pushdef([def_action_if_found], [AS_TR_SH([with_]with_arg)=yes])
+m4_pushdef([def_action_if_not_found], [AS_TR_SH([with_]with_arg)=no])
+
+m4_case(def_arg,
+            [yes],[m4_pushdef([with_without], [--without-]with_arg)],
+            [m4_pushdef([with_without],[--with-]with_arg)])
+
+AC_ARG_WITH(with_arg,
+     AS_HELP_STRING(with_without, description[ @<:@default=]def_arg[@:>@]),,
+    [AS_TR_SH([with_]with_arg)=def_arg])
+
+AS_CASE([$AS_TR_SH([with_]with_arg)],
+            [yes],[PKG_CHECK_MODULES([$1],[$2],$3,$4)],
+            [auto],[PKG_CHECK_MODULES([$1],[$2],
+                                        [m4_n([def_action_if_found]) $3],
+                                        [m4_n([def_action_if_not_found]) $4])])
+
+m4_popdef([with_arg])
+m4_popdef([description])
+m4_popdef([def_arg])
+
+])dnl PKG_WITH_MODULES
+
+dnl PKG_HAVE_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [DESCRIPTION], [DEFAULT])
+dnl -----------------------------------------------
+dnl
+dnl Convenience macro to trigger AM_CONDITIONAL after PKG_WITH_MODULES
+dnl check._[VARIABLE-PREFIX] is exported as make variable.
+AC_DEFUN([PKG_HAVE_WITH_MODULES],
+[
+PKG_WITH_MODULES([$1],[$2],,,[$3],[$4])
+
+AM_CONDITIONAL([HAVE_][$1],
+               [test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"])
+])dnl PKG_HAVE_WITH_MODULES
+
+dnl PKG_HAVE_DEFINE_WITH_MODULES(VARIABLE-PREFIX, MODULES,
+dnl   [DESCRIPTION], [DEFAULT])
+dnl ------------------------------------------------------
+dnl
+dnl Convenience macro to run AM_CONDITIONAL and AC_DEFINE after
+dnl PKG_WITH_MODULES check. HAVE_[VARIABLE-PREFIX] is exported as make
+dnl and preprocessor variable.
+AC_DEFUN([PKG_HAVE_DEFINE_WITH_MODULES],
+[
+PKG_HAVE_WITH_MODULES([$1],[$2],[$3],[$4])
+
+AS_IF([test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"],
+        [AC_DEFINE([HAVE_][$1], 1, [Enable ]m4_tolower([$1])[ support])])
+])dnl PKG_HAVE_DEFINE_WITH_MODULES
+
+m4_include([m4/ax_check_openssl.m4])
diff --git a/configure b/configure
index 9286443124..420c07639b 100755
--- a/configure
+++ b/configure
@@ -623,6 +623,9 @@ ac_includes_default="\
 #endif"
 
 ac_subst_vars='LTLIBOBJS
+OPENSSL_LDFLAGS
+OPENSSL_LIBS
+OPENSSL_INCLUDES
 ENSUREPIP
 SRCDIRS
 THREADHEADERS
@@ -837,6 +839,7 @@ with_libc
 enable_big_digits
 with_computed_gotos
 with_ensurepip
+with_openssl
 '
       ac_precious_vars='build_alias
 host_alias
@@ -1545,6 +1537,7 @@ Optional Packages:
                           default on supported compilers)
   --with(out)-ensurepip=[=upgrade]
                           "install" or "upgrade" using bundled pip
+  --with-openssl=DIR      root of the OpenSSL directory
 
 Some influential environment variables:
   MACHDEP     name for machine-dependent library files
@@ -2687,6 +2680,8 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 
 
+
+
 if test "$srcdir" != . -a "$srcdir" != "$(pwd)"; then
     # If we're building out-of-tree, we need to make sure the following
     # resources get picked up before their $srcdir counterparts.
@@ -16681,6 +16676,265 @@ $as_echo "#define HAVE_GETRANDOM 1" >>confdefs.h
 
 fi
 
+# Check for usable OpenSSL
+
+    found=false
+
+# Check whether --with-openssl was given.
+if test "${with_openssl+set}" = set; then :
+  withval=$with_openssl;
+            case "$withval" in
+            "" | y | ye | yes | n | no)
+            as_fn_error $? "Invalid --with-openssl value" "$LINENO" 5
+              ;;
+            *) ssldirs="$withval"
+              ;;
+            esac
+
+else
+
+            # if pkg-config is installed and openssl has installed a .pc file,
+            # then use that information and don't search ssldirs
+            if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_PKG_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$PKG_CONFIG"; then
+  ac_cv_prog_PKG_CONFIG="$PKG_CONFIG" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_PKG_CONFIG="${ac_tool_prefix}pkg-config"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+PKG_CONFIG=$ac_cv_prog_PKG_CONFIG
+if test -n "$PKG_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PKG_CONFIG" >&5
+$as_echo "$PKG_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_prog_PKG_CONFIG"; then
+  ac_ct_PKG_CONFIG=$PKG_CONFIG
+  # Extract the first word of "pkg-config", so it can be a program name with args.
+set dummy pkg-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_ac_ct_PKG_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$ac_ct_PKG_CONFIG"; then
+  ac_cv_prog_ac_ct_PKG_CONFIG="$ac_ct_PKG_CONFIG" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_ac_ct_PKG_CONFIG="pkg-config"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_PKG_CONFIG=$ac_cv_prog_ac_ct_PKG_CONFIG
+if test -n "$ac_ct_PKG_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_PKG_CONFIG" >&5
+$as_echo "$ac_ct_PKG_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_ct_PKG_CONFIG" = x; then
+    PKG_CONFIG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PKG_CONFIG=$ac_ct_PKG_CONFIG
+  fi
+else
+  PKG_CONFIG="$ac_cv_prog_PKG_CONFIG"
+fi
+
+            if test x"$PKG_CONFIG" != x""; then
+                OPENSSL_LDFLAGS=`$PKG_CONFIG openssl --libs-only-L 2>/dev/null`
+                if test $? = 0; then
+                    OPENSSL_LIBS=`$PKG_CONFIG openssl --libs-only-l 2>/dev/null`
+                    OPENSSL_INCLUDES=`$PKG_CONFIG openssl --cflags-only-I 2>/dev/null`
+                    found=true
+                fi
+            fi
+
+            # no such luck; use some default ssldirs
+            if ! $found; then
+                ssldirs="/usr/local/ssl /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr"
+            fi
+
+
+fi
+
+
+
+    # note that we #include <openssl/foo.h>, so the OpenSSL headers have to be in
+    # an 'openssl' subdirectory
+
+    if ! $found; then
+        OPENSSL_INCLUDES=
+        for ssldir in $ssldirs; do
+            { $as_echo "$as_me:${as_lineno-$LINENO}: checking for openssl/ssl.h in $ssldir" >&5
+$as_echo_n "checking for openssl/ssl.h in $ssldir... " >&6; }
+            if test -f "$ssldir/include/openssl/ssl.h"; then
+                OPENSSL_INCLUDES="-I$ssldir/include"
+                OPENSSL_LDFLAGS="-L$ssldir/lib"
+                OPENSSL_LIBS="-lssl -lcrypto"
+                found=true
+                { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+                break
+            else
+                { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+            fi
+        done
+
+        # if the file wasn't found, well, go ahead and try the link anyway -- maybe
+        # it will just work!
+    fi
+
+    # try the preprocessor and linker with our new flags,
+    # being careful not to pollute the global LIBS, LDFLAGS, and CPPFLAGS
+
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether compiling and linking against OpenSSL works" >&5
+$as_echo_n "checking whether compiling and linking against OpenSSL works... " >&6; }
+    echo "Trying link with OPENSSL_LDFLAGS=$OPENSSL_LDFLAGS;" \
+        "OPENSSL_LIBS=$OPENSSL_LIBS; OPENSSL_INCLUDES=$OPENSSL_INCLUDES" >&5
+
+    save_LIBS="$LIBS"
+    save_LDFLAGS="$LDFLAGS"
+    save_CPPFLAGS="$CPPFLAGS"
+    LDFLAGS="$LDFLAGS $OPENSSL_LDFLAGS"
+    LIBS="$OPENSSL_LIBS $LIBS"
+    CPPFLAGS="$OPENSSL_INCLUDES $CPPFLAGS"
+    cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <openssl/ssl.h>
+int
+main ()
+{
+SSL_new(NULL)
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+
+            { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+            have_openssl=yes
+
+else
+
+            { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+            have_openssl=no
+
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+    CPPFLAGS="$save_CPPFLAGS"
+    LDFLAGS="$save_LDFLAGS"
+    LIBS="$save_LIBS"
+
+
+
+
+
+
+if test "$have_openssl" = yes; then
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for X509_VERIFY_PARAM_set1_host in libssl" >&5
+$as_echo_n "checking for X509_VERIFY_PARAM_set1_host in libssl... " >&6; }
+
+    save_LIBS="$LIBS"
+    save_LDFLAGS="$LDFLAGS"
+    save_CPPFLAGS="$CPPFLAGS"
+    LDFLAGS="$LDFLAGS $OPENSSL_LDFLAGS"
+    LIBS="$OPENSSL_LIBS $LIBS"
+    CPPFLAGS="$OPENSSL_INCLUDES $CPPFLAGS"
+
+    cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+        #include <openssl/x509_vfy.h>
+
+int
+main ()
+{
+
+        X509_VERIFY_PARAM *p = X509_VERIFY_PARAM_new();
+        X509_VERIFY_PARAM_set1_host(p, "localhost", 0);
+        X509_VERIFY_PARAM_set1_ip_asc(p, "127.0.0.1");
+        X509_VERIFY_PARAM_set_hostflags(p, 0);
+
+  ;
+  return 0;
+}
+
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+
+        ac_cv_has_x509_verify_param_set1_host=yes
+
+else
+
+        ac_cv_has_x509_verify_param_set1_host=no
+
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+    { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_has_x509_verify_param_set1_host" >&5
+$as_echo "$ac_cv_has_x509_verify_param_set1_host" >&6; }
+    if test "$ac_cv_has_x509_verify_param_set1_host" = "yes"; then
+
+$as_echo "#define HAVE_X509_VERIFY_PARAM_SET1_HOST 1" >>confdefs.h
+
+    fi
+
+    CPPFLAGS="$save_CPPFLAGS"
+    LDFLAGS="$save_LDFLAGS"
+    LIBS="$save_LIBS"
+fi
+
 # generate output files
 ac_config_files="$ac_config_files Makefile.pre Misc/python.pc Misc/python-config.sh"
 
diff --git a/configure.ac b/configure.ac
index 1894e21f30..39e2e8e769 100644
--- a/configure.ac
+++ b/configure.ac
@@ -9,6 +9,8 @@ AC_PREREQ(2.65)
 
 AC_INIT(python, PYTHON_VERSION, https://bugs.python.org/)
 
+AC_CONFIG_MACRO_DIR(m4)
+
 AC_SUBST(BASECPPFLAGS)
 if test "$srcdir" != . -a "$srcdir" != "$(pwd)"; then
     # If we're building out-of-tree, we need to make sure the following
@@ -5460,6 +5462,45 @@ if test "$have_getrandom" = yes; then
               [Define to 1 if the getrandom() function is available])
 fi
 
+# Check for usable OpenSSL
+AX_CHECK_OPENSSL([have_openssl=yes],[have_openssl=no])
+
+if test "$have_openssl" = yes; then
+    AC_MSG_CHECKING([for X509_VERIFY_PARAM_set1_host in libssl])
+
+    save_LIBS="$LIBS"
+    save_LDFLAGS="$LDFLAGS"
+    save_CPPFLAGS="$CPPFLAGS"
+    LDFLAGS="$LDFLAGS $OPENSSL_LDFLAGS"
+    LIBS="$OPENSSL_LIBS $LIBS"
+    CPPFLAGS="$OPENSSL_INCLUDES $CPPFLAGS"
+
+    AC_LINK_IFELSE([AC_LANG_PROGRAM([
+        [#include <openssl/x509_vfy.h>]
+    ], [
+        [X509_VERIFY_PARAM *p = X509_VERIFY_PARAM_new();]
+        [X509_VERIFY_PARAM_set1_host(p, "localhost", 0);]
+        [X509_VERIFY_PARAM_set1_ip_asc(p, "127.0.0.1");]
+        [X509_VERIFY_PARAM_set_hostflags(p, 0);]
+    ])
+    ],
+    [
+        ac_cv_has_x509_verify_param_set1_host=yes
+    ],
+    [
+        ac_cv_has_x509_verify_param_set1_host=no
+    ])
+    AC_MSG_RESULT($ac_cv_has_x509_verify_param_set1_host)
+    if test "$ac_cv_has_x509_verify_param_set1_host" = "yes"; then
+        AC_DEFINE(HAVE_X509_VERIFY_PARAM_SET1_HOST, 1,
+        [Define if libssl has X509_VERIFY_PARAM_set1_host and related function])
+    fi
+
+    CPPFLAGS="$save_CPPFLAGS"
+    LDFLAGS="$save_LDFLAGS"
+    LIBS="$save_LIBS"
+fi
+
 # generate output files
 AC_CONFIG_FILES(Makefile.pre Misc/python.pc Misc/python-config.sh)
 AC_CONFIG_FILES([Modules/ld_so_aix], [chmod +x Modules/ld_so_aix])
diff --git a/m4/ax_check_openssl.m4 b/m4/ax_check_openssl.m4
new file mode 100644
index 0000000000..28e48cbefb
--- /dev/null
+++ b/m4/ax_check_openssl.m4
@@ -0,0 +1,124 @@
+# ===========================================================================
+#     https://www.gnu.org/software/autoconf-archive/ax_check_openssl.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AX_CHECK_OPENSSL([action-if-found[, action-if-not-found]])
+#
+# DESCRIPTION
+#
+#   Look for OpenSSL in a number of default spots, or in a user-selected
+#   spot (via --with-openssl).  Sets
+#
+#     OPENSSL_INCLUDES to the include directives required
+#     OPENSSL_LIBS to the -l directives required
+#     OPENSSL_LDFLAGS to the -L or -R flags required
+#
+#   and calls ACTION-IF-FOUND or ACTION-IF-NOT-FOUND appropriately
+#
+#   This macro sets OPENSSL_INCLUDES such that source files should use the
+#   openssl/ directory in include directives:
+#
+#     #include <openssl/hmac.h>
+#
+# LICENSE
+#
+#   Copyright (c) 2009,2010 Zmanda Inc. <http://www.zmanda.com/>
+#   Copyright (c) 2009,2010 Dustin J. Mitchell <dustin@zmanda.com>
+#
+#   Copying and distribution of this file, with or without modification, are
+#   permitted in any medium without royalty provided the copyright notice
+#   and this notice are preserved. This file is offered as-is, without any
+#   warranty.
+
+#serial 10
+
+AU_ALIAS([CHECK_SSL], [AX_CHECK_OPENSSL])
+AC_DEFUN([AX_CHECK_OPENSSL], [
+    found=false
+    AC_ARG_WITH([openssl],
+        [AS_HELP_STRING([--with-openssl=DIR],
+            [root of the OpenSSL directory])],
+        [
+            case "$withval" in
+            "" | y | ye | yes | n | no)
+            AC_MSG_ERROR([Invalid --with-openssl value])
+              ;;
+            *) ssldirs="$withval"
+              ;;
+            esac
+        ], [
+            # if pkg-config is installed and openssl has installed a .pc file,
+            # then use that information and don't search ssldirs
+            AC_CHECK_TOOL([PKG_CONFIG], [pkg-config])
+            if test x"$PKG_CONFIG" != x""; then
+                OPENSSL_LDFLAGS=`$PKG_CONFIG openssl --libs-only-L 2>/dev/null`
+                if test $? = 0; then
+                    OPENSSL_LIBS=`$PKG_CONFIG openssl --libs-only-l 2>/dev/null`
+                    OPENSSL_INCLUDES=`$PKG_CONFIG openssl --cflags-only-I 2>/dev/null`
+                    found=true
+                fi
+            fi
+
+            # no such luck; use some default ssldirs
+            if ! $found; then
+                ssldirs="/usr/local/ssl /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr"
+            fi
+        ]
+        )
+
+
+    # note that we #include <openssl/foo.h>, so the OpenSSL headers have to be in
+    # an 'openssl' subdirectory
+
+    if ! $found; then
+        OPENSSL_INCLUDES=
+        for ssldir in $ssldirs; do
+            AC_MSG_CHECKING([for openssl/ssl.h in $ssldir])
+            if test -f "$ssldir/include/openssl/ssl.h"; then
+                OPENSSL_INCLUDES="-I$ssldir/include"
+                OPENSSL_LDFLAGS="-L$ssldir/lib"
+                OPENSSL_LIBS="-lssl -lcrypto"
+                found=true
+                AC_MSG_RESULT([yes])
+                break
+            else
+                AC_MSG_RESULT([no])
+            fi
+        done
+
+        # if the file wasn't found, well, go ahead and try the link anyway -- maybe
+        # it will just work!
+    fi
+
+    # try the preprocessor and linker with our new flags,
+    # being careful not to pollute the global LIBS, LDFLAGS, and CPPFLAGS
+
+    AC_MSG_CHECKING([whether compiling and linking against OpenSSL works])
+    echo "Trying link with OPENSSL_LDFLAGS=$OPENSSL_LDFLAGS;" \
+        "OPENSSL_LIBS=$OPENSSL_LIBS; OPENSSL_INCLUDES=$OPENSSL_INCLUDES" >&AS_MESSAGE_LOG_FD
+
+    save_LIBS="$LIBS"
+    save_LDFLAGS="$LDFLAGS"
+    save_CPPFLAGS="$CPPFLAGS"
+    LDFLAGS="$LDFLAGS $OPENSSL_LDFLAGS"
+    LIBS="$OPENSSL_LIBS $LIBS"
+    CPPFLAGS="$OPENSSL_INCLUDES $CPPFLAGS"
+    AC_LINK_IFELSE(
+        [AC_LANG_PROGRAM([#include <openssl/ssl.h>], [SSL_new(NULL)])],
+        [
+            AC_MSG_RESULT([yes])
+            $1
+        ], [
+            AC_MSG_RESULT([no])
+            $2
+        ])
+    CPPFLAGS="$save_CPPFLAGS"
+    LDFLAGS="$save_LDFLAGS"
+    LIBS="$save_LIBS"
+
+    AC_SUBST([OPENSSL_INCLUDES])
+    AC_SUBST([OPENSSL_LIBS])
+    AC_SUBST([OPENSSL_LDFLAGS])
+])
diff --git a/pyconfig.h.in b/pyconfig.h.in
index ff1083ae0b..dd7c62bad1 100644
--- a/pyconfig.h.in
+++ b/pyconfig.h.in
@@ -1237,6 +1237,9 @@
 /* Define to 1 if you have the `writev' function. */
 #undef HAVE_WRITEV
 
+/* Define if libssl has X509_VERIFY_PARAM_set1_host and related function */
+#undef HAVE_X509_VERIFY_PARAM_SET1_HOST
+
 /* Define if the zlib library has inflateCopy */
 #undef HAVE_ZLIB_COPY
 
diff --git a/setup.py b/setup.py
index 8e98fdcb7e..c23628a2a9 100644
--- a/setup.py
+++ b/setup.py
@@ -860,74 +860,15 @@ def detect_modules(self):
         exts.append( Extension('_socket', ['socketmodule.c'],
                                depends = ['socketmodule.h']) )
         # Detect SSL support for the socket module (via _ssl)
-        search_for_ssl_incs_in = [
-                              '/usr/local/ssl/include',
-                              '/usr/contrib/ssl/include/'
-                             ]
-        ssl_incs = find_file('openssl/ssl.h', inc_dirs,
-                             search_for_ssl_incs_in
-                             )
-        if ssl_incs is not None:
-            krb5_h = find_file('krb5.h', inc_dirs,
-                               ['/usr/kerberos/include'])
-            if krb5_h:
-                ssl_incs += krb5_h
-        ssl_libs = find_library_file(self.compiler, 'ssl',lib_dirs,
-                                     ['/usr/local/ssl/lib',
-                                      '/usr/contrib/ssl/lib/'
-                                     ] )
-
-        if (ssl_incs is not None and
-            ssl_libs is not None):
-            exts.append( Extension('_ssl', ['_ssl.c'],
-                                   include_dirs = ssl_incs,
-                                   library_dirs = ssl_libs,
-                                   libraries = ['ssl', 'crypto'],
-                                   depends = ['socketmodule.h']), )
+        ssl_ext, hashlib_ext = self._detect_openssl(inc_dirs, lib_dirs)
+        if ssl_ext is not None:
+            exts.append(ssl_ext)
         else:
             missing.append('_ssl')
-
-        # find out which version of OpenSSL we have
-        openssl_ver = 0
-        openssl_ver_re = re.compile(
-            r'^\s*#\s*define\s+OPENSSL_VERSION_NUMBER\s+(0x[0-9a-fA-F]+)' )
-
-        # look for the openssl version header on the compiler search path.
-        opensslv_h = find_file('openssl/opensslv.h', [],
-                inc_dirs + search_for_ssl_incs_in)
-        if opensslv_h:
-            name = os.path.join(opensslv_h[0], 'openssl/opensslv.h')
-            if host_platform == 'darwin' and is_macosx_sdk_path(name):
-                name = os.path.join(macosx_sdk_root(), name[1:])
-            try:
-                with open(name, 'r') as incfile:
-                    for line in incfile:
-                        m = openssl_ver_re.match(line)
-                        if m:
-                            openssl_ver = int(m.group(1), 16)
-                            break
-            except IOError as msg:
-                print("IOError while reading opensshv.h:", msg)
-
-        #print('openssl_ver = 0x%08x' % openssl_ver)
-        min_openssl_ver = 0x00907000
-        have_any_openssl = ssl_incs is not None and ssl_libs is not None
-        have_usable_openssl = (have_any_openssl and
-                               openssl_ver >= min_openssl_ver)
-
-        if have_any_openssl:
-            if have_usable_openssl:
-                # The _hashlib module wraps optimized implementations
-                # of hash functions from the OpenSSL library.
-                exts.append( Extension('_hashlib', ['_hashopenssl.c'],
-                                       depends = ['hashlib.h'],
-                                       include_dirs = ssl_incs,
-                                       library_dirs = ssl_libs,
-                                       libraries = ['ssl', 'crypto']) )
-            else:
-                print("warning: openssl 0x%08x is too old for _hashlib" %
-                      openssl_ver)
-                missing.append('_hashlib')
+        if hashlib_ext is not None:
+            exts.append(hashlib_ext)
+        else:
+            missing.append('_hashlib')
 
         # We always compile these even when OpenSSL is available (issue #14693).
         # It's harmless and the object code is tiny (40-50 KiB per module,
@@ -2183,6 +2124,61 @@ def _decimal_ext(self):
         )
         return ext
 
+    def _detect_openssl(self, inc_dirs, lib_dirs):
+        config_vars = sysconfig.get_config_vars()
+
+        def split_var(name, sep):
+            # poor man's shlex, the re module is not available yet.
+            value = config_vars.get(name)
+            if not value:
+                return ()
+            # This trick works because ax_check_openssl uses --libs-only-L,
+            # --libs-only-l, and --cflags-only-I.
+            value = ' ' + value
+            sep = ' ' + sep
+            return [v.strip() for v in value.split(sep) if v.strip()]
+
+        openssl_includes = split_var('OPENSSL_INCLUDES', '-I')
+        openssl_libdirs = split_var('OPENSSL_LDFLAGS', '-L')
+        openssl_libs = split_var('OPENSSL_LIBS', '-l')
+        if not openssl_libs:
+            # libssl and libcrypto not found
+            return None, None
+
+        # Find OpenSSL includes
+        ssl_incs = find_file(
+            'openssl/ssl.h', inc_dirs, openssl_includes
+        )
+        if ssl_incs is None:
+            return None, None
+
+        # OpenSSL 1.0.2 uses Kerberos for KRB5 ciphers
+        krb5_h = find_file(
+            'krb5.h', inc_dirs,
+            ['/usr/kerberos/include']
+        )
+        if krb5_h:
+            ssl_incs.extend(krb5_h)
+
+        ssl_ext = Extension(
+            '_ssl', ['_ssl.c'],
+            include_dirs=openssl_includes,
+            library_dirs=openssl_libdirs,
+            libraries=openssl_libs,
+            depends=['socketmodule.h']
+        )
+
+        hashlib_ext = Extension(
+            '_hashlib', ['_hashopenssl.c'],
+            depends=['hashlib.h'],
+            include_dirs=openssl_includes,
+            library_dirs=openssl_libdirs,
+            libraries=openssl_libs,
+        )
+
+        return ssl_ext, hashlib_ext
+
+
 class PyBuildInstall(install):
     # Suppress the warning about installation into the lib_dynload
     # directory, which is not in sys.path when running Python during
