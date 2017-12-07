TERASOLUNAを採用したシステムのCI/CD環境構築
===========================================

このプロジェクトは、TERASOLUNAのアーキテクチャーが使われたシステムのCI/CD環境を自動構築するためのものである。

以下の前提条件が一致するなら自動構築が可能である。
* TERASOLUNAのアークテクチャーである
* TERASOLUNAはマルチプロジェクト構成である
* ビルドサーバーはCentos7である
* ソースコード管理にはGitlabを使っている
* CIはJenkinsを使う
* プライベートなリポジトリ管理はNexusを使う
* 結合テストサーバーは、AWSのAmazon Linuxである

自動構築されるサーバーは、以下のとおりである。

* ビルドサーバー（※社内にcentos7を用意することを想定）  
  - Nexusのインストール
  - Nexusにプロジェクト専用のプライベートリポジトリを作成
  - Jenkinsのインストール
  - Jenkinsにユーザーを作成（複数プロジェクトが相乗りすることも想定し、プロジェクト毎のユーザーを作成する）
  - Jenkinsにプロジェクトのジョブを作成
  - Gitlabからpull/pushできるようにGilabのJenkinsユーザーに公開キーを登録
* 結合テストサーバー（※AWSのAmazon Linuxを想定）  
  - 簡単のために、機能テストを目的として、tomcatとmysqlがパッケージされたdocker-composeで起動する。
* 本番サーバー
  - TBD

ビルドサーバーが構築されると、同時にTERSOLUNAのブランクプロジェクトがGitlabに登録されて、
Jenkinsにも、夜間にビルドするジョブが登録されるので、なんの追加設定をしなくても、
その日の夜から、ビルドが実行されて、メールでビルド結果がレポートされるようになる。

尚、各サーバーの構築は ansible で自動化している。
ansibleの実行には、事前準備が少しあるので、それを整えてから実行する。

## 事前準備

ansibleは、サーバーの構築手順が記載されたシナリオファイルを元に、各サーバーにsshで接続してサーバー内でシナリオに書かれたコマンドを実行しながら環境を自動構築していく。  
役割は、各サーバーに指示を出す`コントローラー`と、対象となる`ターゲットサーバー`に分かれる。

ansibleは、コントローラと、ターゲットサーバーの両方に、インストールする。  
その次に、コントローラーでsshのキーを作成して、ターゲットサーバーでは、
sshで接続するためのアカウントを作成し、認証済ユーザーとして、 
authorized_keys にコントローラーの公開キーを登録する。

以降に、それぞれの事前準備ついて、詳しく説明する。
説明の便宜上、ターゲットサーバーには ansible というアカウントを作るものとする。

### ansibleのインストール

コントローラー、ターゲットサーバーの両方にインストールする。

* centos7の場合
```
sudo yum -y install ansible
```

* amazon linuxの場合  
```
sudo su - 
yum install -y libffi-devel openssl-devel
pip install --upgrade setuptools
pip install cffi
pip install ansible
```
amazon linuxがマイクロインスタンスなら、メモリが貧弱なので、swapを作成しておく。
```
sudo su -
dd if=/dev/zero of=/swap bs=1M count=2048
chmod 600 /swap
mkswap /swap
swapon /swap
```

* Windowsをコントローラーにする場合  
```
TBD 
```

実際には、もう少し必要な場合もあるのだが、その先は ansible のシナリオで実行することとする。

### コントローラーでsshキーを作成

gitを使っているなら、すでに、キーが作られているので、その公開キーを使うとよい。
```
cat ~/.ssh/id_rsa.pub
```

もし、作成されていないなら、これで作成する。
```
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
chmod 600 ~/.ssh ~/.ssh/id_rsa

# 公開キーを表示する
cat ~/.ssh/id_rsa.pub
```

### ターゲットサーバーでアカウント作成

冒頭で説明したとおり、ansible アカウントを作成する。
```
sudo useradd ansible
sudo su - ansible
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# コントローラーの公開キーを登録する
cat <<EOF >> ~/.ssh/authorized_keys
・・・ここに公開キーを貼り付ける・・・
EOF
```
root で sudoers に追加
```
echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```


### Gitlabにjenkinsユーザーを作成
GitlabにJenkinsからアクセスするための専用のユーザーを作成して、`Private token`をコピーしておく。
`Private token`は、専用ユーザーでログインして、`Profile Settings`メニューから、
さらに`Account`メニューをクリックした画面に表示される。

Private tokenは、ソースコードとして管理したくないので、ansibleを実行するときに、
環境変数として、この Private token を与えるようになっている。

## 環境構築の実行

社内のビルドサーバーの構築
```
export GITLAB_PRIVATE_TOKEN='GitlabのPrivate token'
ansible-playbook -i inventories/build build-servers.yml
```
**(注)**  
jenkinsのプラグインもインストールしているが、プラグインのダウンロードに失敗することが、しばしばあって、`ansible-playbook`がエラーで終了する。  
その場合は、`ansible-playbook`を再実行してほしい。
シナリオの中でのリトライ処理の実装を試みたが難しかったため対策は行っていない。

結合テストサーバーの構築
```
ansible-playbook -i inventories/staging site.yml
```

本番サーバーの構築
```
TBD
```

## シナリオのデバッグ

完成したシナリオを実行するコントローラーは、ローカルPCかもしれないし、Vagrantの中のLinuxかもしれない。あるいは、ansibleがインストールされたDockerコンテナを使うこともあると思う。そのときの事情に合わせて選択すると良いと思う。  

しかし、ansibleのシナリオを作成する過程では、シナリオのデバッグのために、ターゲットサーバーをまっさらな状態から、やり直したいことが多々発生する。  
そのため、シナリオを作成する場合は、destroy と up がやり易い Vagrant を使うと良いような気がする。  

このプロジェクトの`Vagrantfile`は、コントローラーにCentos7、ターゲットとしてのビルドサーバーにCentos7、結合テスト環境としてAmazon linuxの3つのVMを起動する。  
provisionスクリプトでは、上記で説明したansibleのインストールとsshのauthorized_keysの登録までやっている。（コントローラーのsshキーは、ホストOSからssh.forward_agentされることを前提としている）

ansible-playbook では、--connection=local をオプションに加えることで、ローカルホストをターゲットサーバーにすることができて、この場合は ssh も使われない。
当面のデバッグは、ローカルホストに対して実行した方が、効率がよい。  
例えば、ビルドサーバーの構築は、以下のコマンドで、ローカルホストに対して実行する。
```
ansible-playbook -i inventories/local build-servers.yml --connection=local
```
**(注)**  
inventories/local にすること。  
jenkinsやnexusのインストール後、httpでアクセスするため、URL自体は、ローカル環境の設定になっている必要があるため。
