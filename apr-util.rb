require "formula"

class AprUtil < Formula
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-util-1.5.4.tar.bz2"
  sha1 "b00038b5081472ed094ced28bcbf2b5bb56c589d"

  keg_only :provided_by_osx

  depends_on "apr"
  depends_on "mysql-connector-c" => :optional

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
    system "make", "install"
  end
end
