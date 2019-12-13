Chef::Log.info("Install os package")
yum_package 'gcc-c++'
yum_package 'nodejs'
yum_package 'ImageMagick'
yum_package 'ImageMagick-devel'
yum_package 'redis'
yum_package 'ipa-gothic-fonts'

# mozjpegをインストール
Chef::Log.info("Install mozjpeg")
bash 'install_mozjpeg' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    if type "/usr/local/bin/mozjpeg" > /dev/null 2>&1 ; then
      echo "mozjpeg exist"
    else
      echo "mozjpeg new"
      curl -LO https://github.com/mozilla/mozjpeg/releases/download/v3.2-pre/mozjpeg-3.2-release-source.tar.gz
      tar xf mozjpeg-3.2-release-source.tar.gz
      yum -y install automake gcc nasm jpegoptim
      cd mozjpeg
      ./configure
      make
      make install
      ln -s /opt/mozjpeg/bin/* /usr/local/bin
      ln -s /opt/mozjpeg/share/man/man1/* /usr/local/share/man/man1
      ln -s /opt/mozjpeg/bin/jpegtran /usr/local/bin/mozjpeg
    fi
  EOH
end

# JSTに設定
Chef::Log.info("Set JST")
link "/etc/localtime" do
  to "/usr/share/zoneinfo/Japan"
end

# cronを再起動させてJSTにする
Chef::Log.info("Cron restart for JST")
bash 'crontab_restart' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    /etc/init.d/crond restart
  EOH
end