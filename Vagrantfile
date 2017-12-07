# encoding: utf-8

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # ansibleのコントローラー
  config.vm.define "controller" do |node|
    node.vm.box = "centos/7"
    node.vm.hostname = "controller"
    # ssh-agentでforwardする
    node.ssh.forward_agent = true
    # IPアドレス
    node.vm.network :private_network, ip: "192.168.33.10"
    # 共有フォルダ
    node.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    node.vm.provider :virtualbox do |vb|
      # メモリはプロジェクトに合わせて変更する
      vb.customize ["modifyvm", :id, "--memory", 512]
    end
    node.vm.provision :shell, :inline => <<-EOT
      # Ansibleのインストール
      yum -y install ansible
      
      # .env.shを読み込む
      . /vagrant/.env.sh

      # ホストを登録
      echo "$NEXUS_HOST nexus.local" >> /etc/hosts
      echo "$JENKINS_HOST jenkins.local" >> /etc/hosts

      # .bash_profileに.env.shの読み込みを登録
      echo '. /vagrant/.env.sh' >> /home/vagrant/.bash_profile
    EOT
  end

end
