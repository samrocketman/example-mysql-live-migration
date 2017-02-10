# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  # https://www.vagrantup.com/docs/multi-machine/

  #source database configuration
  config.vm.define "src_db" do |src_db|
    src_db.vm.box = "centos/7"
    src_db.vm.network "forwarded_port", guest: 3306, host: 3333
    src_db.vm.provider "virtualbox" do |vb|
      vb.cpus = "4"
      vb.memory = "4096"
    end
    src_db.vm.provision "shell", inline: <<-SHELL
      yum makecache fast
      yum install -y mariadb mariadb-server git vim
      service mariadb start
      cat > /tmp/user.sql <<'EOF'
CREATE USER 'datasync'@'%' IDENTIFIED BY 'syncpw';
GRANT ALL PRIVILEGES ON employees.* TO 'datasync'@'%';
EOF
      mysql < /tmp/user.sql

      #populate DB with dummy data
      git clone https://github.com/datacharmer/test_db
      pushd test_db
      mysql < ./employees_partitioned.sql
      popd
      rm -rf test_db
    SHELL
  end

  #destination database configuration
  config.vm.define "dst_db" do |dst_db|
    dst_db.vm.box = "centos/7"
    dst_db.vm.network "forwarded_port", guest: 3306, host: 3334
    dst_db.vm.provider "virtualbox" do |vb|
      vb.cpus = "4"
      vb.memory = "4096"
    end
    dst_db.vm.provision "shell", inline: <<-SHELL
      yum makecache fast
      yum install -y mariadb mariadb-server git vim
      service mariadb start
      cat > /tmp/user.sql <<'EOF'
CREATE USER 'datasync'@'%' IDENTIFIED BY 'syncpw';
GRANT ALL PRIVILEGES ON employees.* TO 'datasync'@'%';
EOF
      mysql < /tmp/user.sql
    SHELL
  end
end
