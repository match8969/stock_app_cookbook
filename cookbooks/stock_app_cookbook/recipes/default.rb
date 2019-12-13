Chef::Log.info("Install os package")
execute 'yum-config-manager --enable epel'
yum_package 'gcc-c++'
yum_package 'bzip2'
yum_package 'gcc'
yum_package 'openssl-devel'
yum_package 'readline-devel'
yum_package 'zlib-devel'
yum_package 'nodejs'
yum_package 'git'
yum_package 'ImageMagick'
yum_package 'ImageMagick-devel'
yum_package 'redis'
yum_package 'ipa-gothic-fonts'

# JSTに設定
Chef::Log.info("Set JST")
link "/etc/localtime" do
  to "/usr/share/zoneinfo/Japan"
end

# opsworks_rubyの準備コード
include_recipe 'apt'
prepare_recipe

# デプロイユーザーの作成
group node['deployer']['group'] do
  gid 5000
end

user node['deployer']['user'] do
  comment 'The deployment user'
  uid 5000
  gid 5000
  shell '/bin/bash'
  home node['deployer']['home']
  manage_home true
end

sudo node['deployer']['user'] do
  user      node['deployer']['user']
  group     node['deployer']['group']
  commands  %w[ALL]
  host      'ALL'
  nopasswd  true
end

# rubyをインストール
Chef::Log.info("Install ruby")
ruby_version = "2.6.5" # TODO from node
bash 'install_ruby' do
  user "root"
  cwd "/tmp"
  code <<-EOH
    if type "/usr/local/bin/ruby" > /dev/null 2>&1 ; then
      echo "ruby exist"
    else
      yum -y erase ruby
      cd /usr/local
      git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
      touch /etc/profile.d/rbenv.sh
      echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile.d/rbenv.sh
      echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
      echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
      git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build
      chmod -R 777 /opt/rbenv
      source /etc/profile.d/rbenv.sh
      rbenv install #{ruby_version}
      rbenv rehash
      rbenv global #{ruby_version}
    fi
  EOH
end

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

# cronを再起動させてJSTにする
Chef::Log.info("Cron restart for JST")
bash 'crontab_restart' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    /etc/init.d/crond restart
  EOH
end


