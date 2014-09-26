require 'formula'

class ModSecurity < Formula
  homepage 'http://www.modsecurity.org/'
  url 'https://www.modsecurity.org/tarball/2.8.0/modsecurity-2.8.0.tar.gz'
  sha1 '0ac3931806468eef616ee2301c98b3dd1f567f7c'

  depends_on 'pcre'

  option 'with-brewed-apr', 'Use Homebrew apr'
  option 'with-brewed-httpd22', 'Use Homebrew Apache httpd 2.2'
  option 'with-brewed-httpd24', 'Use Homebrew Apache httpd 2.4'

  depends_on 'apr' if build.with? 'brewed-apr'
  depends_on 'httpd22' if build.with? 'brewed-httpd22'
  depends_on 'httpd24' if build.with? 'brewed-httpd24'

  depends_on 'automake'
  depends_on 'libtool'

  def apache_apxs
    if build.with? 'brewed-httpd22'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd22'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    elsif build.with? 'brewed-httpd24'
      ['sbin', 'bin'].each do |dir|
        if File.exist?(location = "#{Formula['httpd24'].opt_prefix}/#{dir}/apxs")
          return location
        end
      end
    else
      '/usr/sbin/apxs'
    end
  end

  def apache_configdir
    if build.with? 'brewed-httpd22'
      "#{etc}/apache2/2.2"
    elsif build.with? 'brewed-httpd24'
      "#{etc}/apache2/2.4"
    else
      '/etc/apache2'
    end
  end

  def install
    args = "--prefix=#{prefix}", '--disable-dependency-tracking'
    args << "--with-pcre=#{Formula['pcre'].opt_prefix}"
    args << "--with-apxs=#{apache_apxs}"

    if build.with? 'brewed-httpd22'
      args << "--with-apr=#{Formula['httpd22'].opt_prefix}"
      args << "--with-apu=#{Formula['httpd22'].prefix}/bin"
    elsif build.with? 'brewed-httpd24'
      if build.with? 'brewed-apr'
        args << "--with-apr=#{Formula['apr'].opt_prefix}"
        args << "--with-apu=#{Formula['apr-util'].prefix}/bin"
      else
        args << "--with-apr=#{Formula['httpd24'].opt_prefix}"
        args << "--with-apu=#{Formula['httpd24'].prefix}/bin"
      end
    else
      args << '--with-apr=/usr/bin'
      args << '--with-apu=/usr/bin'
    end

    system './autogen.sh'
    system './configure', *args
    system 'make'

    libexec.install 'apache2/.libs/mod_security2.so'

    # Use Homebrew paths in the sample file
    inreplace 'modsecurity.conf-recommended' do |s|
      s.gsub! ' /var/log', " #{var}/log"
      s.gsub! ' /opt/modsecurity/var', " #{opt_prefix}/var"
    end

    prefix.install 'modsecurity.conf-recommended'
  end

  def caveats; <<-EOS.undent
    You must manually edit #{apache_configdir}/httpd.conf to include
      LoadModule security2_module #{libexec}/mod_security2.so

    You must also uncomment a line similar to the line below in #{apache_configdir}/httpd.conf to enable unique_id_module
      #LoadModule unique_id_module libexec/mod_unique_id.so

    Sample configuration file for Apache is at:
      #{prefix}/modsecurity.conf-recommended

    NOTE: If you're _NOT_ using --with-brewed-httpd22 or --with-brewed-httpd24 and having
    installation problems relating to a missing `cc` compiler and `OSX#{MACOS_VERSION}.xctoolchain`,
    read the "Troubleshooting" section of https://github.com/Homebrew/homebrew-apache
    EOS
  end

end
