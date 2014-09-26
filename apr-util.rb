require 'formula'

class AprUtil < Formula
  homepage 'http://apr.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=apr/apr-util-1.5.3.tar.bz2'
  sha1 'de0184ee03dfdc6dec4d013970d1862251e86925'

  keg_only :provided_by_osx

  depends_on 'homebrew/dupes/apr'
  depends_on 'mysql-connector-c' => :optional

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-apr=#{Formula["apr"].opt_prefix}
    ]
    args << "--with-mysql=#{Formula["mysql-connector-c"].opt_prefix}" if build.with? "mysql-connector-c"

    system "./configure", *args
    system "make"
    system "make install"
  end
end
