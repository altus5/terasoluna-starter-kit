# {{ PROJECT_GROUP }} 開発環境の作り方

## この手順でインストールされるもの

* Vagrant
* VirtualBox
* Eclipse（Pleiades）
* Maven
* Lombok
* {{ PROJECT_GROUP }} のソースコード

## 事前準備

**Bash**  
[Git for Windows](https://git-for-windows.github.io/) をインストールして、Git Bashが実行できるようにしておいてください。  

**Git**  
Git Bashのコンソールで、Gitの設定と、sshキーを作成して、Gitlabに登録しておいてください。
```
git config --global user.name "ほげ"
git config --global user.email "hoge@example.jp"
```
sshキーは以下のコマンドで作成できます。
```
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
chmod 600 ~/.ssh ~/.ssh/id_rsa

# 公開キーを表示する
cat ~/.ssh/id_rsa.pub
```
作成された公開キーをGitlabに登録してください。

VagrantのVMでsshキーを共有するために、ssh-agentが使えるように、以下を実行して、.bash_profile に追記してください。
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
```

## 開発環境の作成

以下のコマンドで、ローカルPCに開発環境を作成してください。
```
curl -sSL  {{ DEVELOPMENT_KIT_REPO_URL }}/raw/develop/bin/init.sh | bash
```
