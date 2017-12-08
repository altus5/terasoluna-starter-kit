# {{ PROJECT_GROUP }} 開発キット

## 開発キット

開発キットの構成は、次の通りです。

```
{{ DEVELOPMENT_KIT_NAME }}
├── eclipse
├── java
├── tomcat
├── maven
├── {{ PROJECT_NAME }}
│   ├── {{ PROJECT_NAME }}-domain
│   ├── {{ PROJECT_NAME }}-env
│   ├── {{ PROJECT_NAME }}-initdb
│   ├── {{ PROJECT_NAME }}-selenium
│   ├── {{ PROJECT_NAME }}-web
│   ├── pom.xml
├── workspace
├── eclipse.bat
├── eclipse-clean.bat
├── Vagrantfile
```

eclipse、java、tomcat、mavenはダウンロードされ展開されます。主に[Pleiades](http://mergedoc.osdn.jp/)にパッケージされているものになります。  

{{ PROJECT_NAME }}は、プロジェクト本体のソースコードで、`{{ DEVELOPMENT_KIT_NAME }}`リポジトリの`submodule`になっています。  
TERASOLUNAのマルチプロジェクト構成になっています。  

eclipse.batは、eclipseを起動するためのもので、次のようになっています。   
```
set BASE_DIR=%cd%
set JAVA_HOME=%BASE_DIR%\java\8
set PATH=%JAVA_HOME%\bin;%PATH%
set M2_HOME=%BASE_DIR%\maven
set PATH=%M2_HOME%\bin;%PATH%
cd %BASE_DIR%\eclipse
start eclipse.exe %1
```
複数の開発プロジェクトを抱えていると、システムの環境変数に設定したくない場合があるので、起動時に設定しています。

## 開発ツール

開発キットの構築で、以下の開発ツールが、自動インストールされます。

* Eclipse（Pleiades）
* Lombok
* Maven
* VirtualBox
* Vagrant

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
```

## 開発キットの構築

以下のコマンドで、ローカルPCに開発環境を作成してください。
```
curl -sSL {{ GITLAB_URL }}/{{ PROJECT_GROUP }}/{{ DEVELOPMENT_KIT_NAME }}/blob/master/init.sh
 | bash
```
