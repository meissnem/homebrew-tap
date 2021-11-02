class RedisAT5 < Formula
  desc "Persistent key-value database, with built-in net interface"
  homepage "https://redis.io/"
  url "https://download.redis.io/releases/redis-5.0.14.tar.gz"
  sha256 "3ea5024766d983249e80d4aa9457c897a9f079957d0fb1f35682df233f997f32"
  license "BSD-3-Clause"

  livecheck do
    url "https://download.redis.io/releases/"
    regex(/href=.*?redis[._-](5(?:\.\d+)+)\.t/i)
  end

  keg_only :versioned_formula

  depends_on "openssl@1.1"

  patch :DATA

  def install
    system "make", "install", "PREFIX=#{prefix}", "CC=#{ENV.cc}", "BUILD_TLS=yes"

    %w[run db/redis@5 log].each { |p| (var/p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", var/"run/redis@5.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis@5/"
      s.sub!(/^bind .*$/, "bind 127.0.0.1 ::1")
    end

    etc.install "redis.conf" => "redis@5.conf"
    etc.install "sentinel.conf" => "redis@5-sentinel.conf"
  end

  plist_options manual: "redis-server #{HOMEBREW_PREFIX}/etc/redis@5.conf"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <dict>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/redis-server</string>
            <string>#{etc}/redis@5.conf</string>
            <string>--daemonize no</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/redis@5.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/redis@5.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    system bin/"redis-server", "--test-memory", "2"
    %w[run db/redis@5 log].each { |p| assert_predicate var/p, :exist?, "#{var/p} doesn't exist!" }
  end
end
__END__
diff --git a/src/debug.c b/src/debug.c
index 351d749..6facc82 100644
--- a/src/debug.c
+++ b/src/debug.c
@@ -53,6 +53,10 @@ typedef ucontext_t sigcontext_t;
 #endif
 #endif
 
+#if defined(__APPLE__) && defined(__arm64__)
+#include <mach/mach.h>
+#endif
+
 /* ================================= Debugging ============================== */
 
 /* Compute the sha1 of string at 's' with 'len' bytes long.
@@ -746,8 +750,11 @@ static void *getMcontextEip(ucontext_t *uc) {
     /* OSX >= 10.6 */
     #if defined(_STRUCT_X86_THREAD_STATE64) && !defined(__i386__)
     return (void*) uc->uc_mcontext->__ss.__rip;
-    #else
+    #elif defined(__i386__)
     return (void*) uc->uc_mcontext->__ss.__eip;
+    #else
+    /* OSX ARM64 */
+    return (void*) arm_thread_state64_get_pc(uc->uc_mcontext->__ss);
     #endif
 #elif defined(__linux__)
     /* Linux */
@@ -833,7 +840,7 @@ void logRegisters(ucontext_t *uc) {
         (unsigned long) uc->uc_mcontext->__ss.__gs
     );
     logStackContent((void**)uc->uc_mcontext->__ss.__rsp);
-    #else
+    #elif defined(__i386__)
     /* OSX x86 */
     serverLog(LL_WARNING,
     "\n"
@@ -859,6 +866,55 @@ void logRegisters(ucontext_t *uc) {
         (unsigned long) uc->uc_mcontext->__ss.__gs
     );
     logStackContent((void**)uc->uc_mcontext->__ss.__esp);
+    #else
+    /* OSX ARM64 */
+    serverLog(LL_WARNING,
+    "\n"
+    "x0:%016lx x1:%016lx x2:%016lx x3:%016lx\n"
+    "x4:%016lx x5:%016lx x6:%016lx x7:%016lx\n"
+    "x8:%016lx x9:%016lx x10:%016lx x11:%016lx\n"
+    "x12:%016lx x13:%016lx x14:%016lx x15:%016lx\n"
+    "x16:%016lx x17:%016lx x18:%016lx x19:%016lx\n"
+    "x20:%016lx x21:%016lx x22:%016lx x23:%016lx\n"
+    "x24:%016lx x25:%016lx x26:%016lx x27:%016lx\n"
+    "x28:%016lx fp:%016lx lr:%016lx\n"
+    "sp:%016lx pc:%016lx cpsr:%08lx\n",
+        (unsigned long) uc->uc_mcontext->__ss.__x[0],
+        (unsigned long) uc->uc_mcontext->__ss.__x[1],
+        (unsigned long) uc->uc_mcontext->__ss.__x[2],
+        (unsigned long) uc->uc_mcontext->__ss.__x[3],
+        (unsigned long) uc->uc_mcontext->__ss.__x[4],
+        (unsigned long) uc->uc_mcontext->__ss.__x[5],
+        (unsigned long) uc->uc_mcontext->__ss.__x[6],
+        (unsigned long) uc->uc_mcontext->__ss.__x[7],
+        (unsigned long) uc->uc_mcontext->__ss.__x[8],
+        (unsigned long) uc->uc_mcontext->__ss.__x[9],
+        (unsigned long) uc->uc_mcontext->__ss.__x[10],
+        (unsigned long) uc->uc_mcontext->__ss.__x[11],
+        (unsigned long) uc->uc_mcontext->__ss.__x[12],
+        (unsigned long) uc->uc_mcontext->__ss.__x[13],
+        (unsigned long) uc->uc_mcontext->__ss.__x[14],
+        (unsigned long) uc->uc_mcontext->__ss.__x[15],
+        (unsigned long) uc->uc_mcontext->__ss.__x[16],
+        (unsigned long) uc->uc_mcontext->__ss.__x[17],
+        (unsigned long) uc->uc_mcontext->__ss.__x[18],
+        (unsigned long) uc->uc_mcontext->__ss.__x[19],
+        (unsigned long) uc->uc_mcontext->__ss.__x[20],
+        (unsigned long) uc->uc_mcontext->__ss.__x[21],
+        (unsigned long) uc->uc_mcontext->__ss.__x[22],
+        (unsigned long) uc->uc_mcontext->__ss.__x[23],
+        (unsigned long) uc->uc_mcontext->__ss.__x[24],
+        (unsigned long) uc->uc_mcontext->__ss.__x[25],
+        (unsigned long) uc->uc_mcontext->__ss.__x[26],
+        (unsigned long) uc->uc_mcontext->__ss.__x[27],
+        (unsigned long) uc->uc_mcontext->__ss.__x[28],
+        (unsigned long) arm_thread_state64_get_fp(uc->uc_mcontext->__ss),
+        (unsigned long) arm_thread_state64_get_lr(uc->uc_mcontext->__ss),
+        (unsigned long) arm_thread_state64_get_sp(uc->uc_mcontext->__ss),
+        (unsigned long) arm_thread_state64_get_pc(uc->uc_mcontext->__ss),
+        (unsigned long) uc->uc_mcontext->__ss.__cpsr
+    );
+    logStackContent((void**) arm_thread_state64_get_sp(uc->uc_mcontext->__ss));
     #endif
 /* Linux */
 #elif defined(__linux__)
