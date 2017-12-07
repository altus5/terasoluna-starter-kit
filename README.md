# TERASOLUNA Starter Kit

TERASOLUNAの開発環境を30分で作成するスターターキットです。  
このキットで、開発チームに配布する開発キットと、CI環境の構築を行うことができます。  

例えば、開発チームのリーダーが、TERASOLUNAの開発プロジェクトの立ち上げに際して、
社内に、プロジェクト専用のCIサーバーを構築して、さらに、チーム内のメンバーに、
開発環境を配布するようなシナリオを想定しています。

配布される開発環境としてコミットされているソースコードは、TERASOLUNAのブランクプロジェクトです。

## 前提条件

いくつかの前提条件を設けることで、手順が簡略化されるので、このキットでも条件を設けています。

* 開発用のPCはWindowsである
* 社内のGitlabでソースコードを管理している（プライベートクラウドでもOK）
* Git Bashを使う
* Git Bashに、sshのキーを作成して、Gitlabにもsshのキーを登録してある
* Vagrant+VirtualBoxを使う
* Eclipseを使う
* 社内にCI用のサーバーがある（プライベートクラウドでもOK）
* CI用のサーバーは Centos7 か Amazon Linux である
* CI用のサーバーは ansible で構築される（ansibleが実行できること）
* CI用のサーバーには、JenkinsとNexusがインストールされる
* JenkinsとNexusは、Dockerコンテナで実行される

## 事前準備

### ローカルPC編

**Bash**  
[Git for Windows](https://git-for-windows.github.io/) をインストールして、Git Bashが実行できるようにしておいてください。  

**Git**  
Git Bashのコンソールで、Gitの設定と、sshキーを作成して、Gitlabに登録しておいてください。
```
git config --global user.name "ほげ太郎"
git config --global user.email "hoge@altus5.local"
```
sshキーは以下のコマンド作成できます。
```
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
chmod 600 ~/.ssh ~/.ssh/id_rsa

# 公開キーを表示する
cat ~/.ssh/id_rsa.pub
```
公開キーをGitlabに登録するために、メモしておきます。

開発環境として、VirtualBox+Vagrantを使います。ローカルPC（ホストOS）とVMとは、ssh-agent を使って、同じsshキーを使います。
Git Bash起動毎に、ssh-agentが実行されるように、以下を実行して、.bash_profile に追加してください。
```
cat << _EOF_ >> ~/.bash_profile
echo -n "ssh-agent: "
if [ -e ~/.ssh-agent-info ]; then
  source ~/.ssh-agent-info
fi
ssh-add -l >&/dev/null
if [ $? == 2 ] ; then
  echo -n "ssh-agent: restart...."
  ssh-agent >~/.ssh-agent-info
  source ~/.ssh-agent-info
fi

if ssh-add -l >&/dev/null ; then
  echo "ssh-agent: Identity is already stored."
else
  ssh-add ~/.ssh/id_rsa
fi
_EOF_
# 再読み込み
. ~/.bash_profile
```

### Gitlab編

配布する開発キットは、Gitlabのリポジトリとしてチーム内で共有します。  

**リポジトリOwnerの作成**  
Gitlabに、リポジトリOwnerとなるユーザー（つまり自分のアカウント）を作成してください。  
作成されたアカウントには、ローカルPC編で作成したsshの公開キーを設定してください。  
また、開発キットのリポジトリ作成も、GitlabのAPIを使ってスクリプトから実行します。  
APIの実行には、リポジトリのOwnerとなるユーザーの`Private token`が必要なので、
Gitlabの自分のプロファイルを見て、メモしておいてください。

**jenkinsユーザーを作成**  
Jenkinsからもソースコードの取得などで、アクセスされます。
専用の`jenkins`ユーザーを作成してください。  
また、このユーザーについても、`Private token`をメモしておきます。

### CIサーバー編

JenkinsとNexusを実行するサーバーを準備してください。  
同じサーバーに同居させることも可能です。  

**Ansible用のユーザー作成**  
JenkinsとNexusは、Ansibleを使ってインストールされます。  
Ansibleの前提として、sshでの接続が認証済になっている必要があります。  
JenkinsとNexusをインストールするサーバーに、`ansible`というユーザーを作成して、
authorized_keys にローカルPCの公開キーを登録します。  
以下の手順をJenkinsとNexusサーバーで行ってください。（同一のサーバーでも可）  
```
sudo useradd ansible
sudo su - ansible
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# ローカルPCの公開キーを登録する
cat <<_EOF_ > ~/.ssh/authorized_keys
・・・・ここをローカルPCの公開キーで置き換える・・・・
_EOF_

exit

# ansible をインストール
sudo su -
## Centos7の場合
sudo yum -y install ansible
## amazon linux の場合
yum install -y libffi-devel openssl-devel
pip install --upgrade setuptools
pip install cffi
pip install ansible

# sudoers に追加
echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

## プロジェクトの構成情報

ローカルPCで、本リポジトリを clone してください。
```
# スターターキットをclone
git clone git@github.com:altus5/terasoluna-starter-kit.git
cd terasoluna-starter-kit
```

構築するサーバーの情報や、プロジェクト名などのプロジェクトの構成情報を
環境変数として登録することで、bashスクリプトが、自動的に環境を作ります。  
`.env.example.sh` をコピーして `.env.sh` を作成して編集してください。  
Gitlab編でメモした2つの`Private token`も、ここに設定します。

```
# 環境構築のための各種設定を定義
cp .env.example.sh .env.sh
##・・・.env.shを編集・・・
```

## CI環境の構築

TERASOLUNAのブランクプロジェクトを作成するには、Mavenが動くことと、且つ、その時点で、Nexusも設置されていた方が効率がよいので、最初に、CI環境を作成します。

```
# CI環境を作成
./scripts/setup-ci.sh
```
このスクリプトでは、ansibleを実行するために、VirtualBoxとVagrantのインストールも行います。ansibleは、VMの中から実行されます。

## 開発チームに配布する開発キットを作成する

```
# 開発メンバーに配布する開発キットを作成
./scripts/create-starter-kit.sh
```
Gitlabにブランクプロジェクトもプッシュされます。

開発リーダーの方が、ここまでの作業を行うと、`./development-kit` というディレクトリが作成されて、ここに、チームに配布する開発キットと同じものが作成された状態になります。  
リーダーは、このディレクトリをそのまま使って、開発を進めて問題ありません。

## 開発チームへの展開

開発チームのメンバーに、開発環境構築手順を案内して、各自のPCに環境を作成してもらいます。
構築手順も、開発キットのREADMEとしてコミットされているので、リポジトリURLの案内だけで、進められます。

