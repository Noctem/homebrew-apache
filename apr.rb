require 'formula'

class Apr < Formula
  homepage 'http://apr.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=apr/apr-1.5.1.tar.bz2'
  sha1 'f94e4e0b678282e0704e573b5b2fe6d48bd1c309'

  keg_only :provided_by_osx

  # Configure switch unconditionally adds the -no-cpp-precomp switch
  # to CPPFLAGS, which is an obsolete Apple-only switch that breaks
  # builds under non-Apple compilers and which may or may not do anything
  # anymore.
  # Reported upstream: https://issues.apache.org/bugzilla/show_bug.cgi?id=48483
  patch :DATA

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make install"
  end
end

__END__
diff --git a/configure b/configure
index 00122df..e64f479 100755
--- a/configure
+++ b/configure
@@ -6820,10 +6820,10 @@ if test "x$apr_preload_done" != "xyes" ; then
     *-apple-darwin*)
 
   if test "x$CPPFLAGS" = "x"; then
-    test "x$silent" != "xyes" && echo "  setting CPPFLAGS to \"-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp\""
-    CPPFLAGS="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp"
+    test "x$silent" != "xyes" && echo "  setting CPPFLAGS to \"-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK\""
+    CPPFLAGS="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK"
   else
-    apr_addto_bugger="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp"
+    apr_addto_bugger="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK"
     for i in $apr_addto_bugger; do
       apr_addto_duplicate="0"
       for j in $CPPFLAGS; do
