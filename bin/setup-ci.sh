#!/bin/bash
# ./setup-ci.sh

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

basedir=$(cd $(dirname $0) && pwd)
rootdir=$basedir/..
cd $rootdir

# プロジェクトの構成を取り込み
. ./bin/config.sh

# virtualboxとvagrantをインストールする
./bin/setup-vbox-vagrant.sh

# vagrantでansibleを実行する
vagrant up
vagrant ssh -c "cd /vagrant/ansible && ansible-playbook -i inventories/build build-servers.yml"

# .m2/settings.xml を作成する
./bin/render-templates.sh ./m2/settings.xml .
if [ -e $HOME/.m2/settings.xml ]; then
  md5new=`md5sum settings.xml | awk '{ print $1 }'`
  md5old=`md5sum $HOME/.m2/settings.xml | awk '{ print $1 }'`
  if [ "$md5new" != "$md5old" ]; then
    _backupfile=$HOME/.m2/settings.xml.$PROJECT_GROUP-starter-kit
    mv -f settings.xml $_backupfile
    echo "!!要確認!! terasoluna用の setting.xml を $_backupfile に作成しました。$HOME/.m2/settings.xml が既に存在するので、手動でマージしてください。"
  else
    rm -f settings.xml
  fi
else
  mv -f settings.xml $HOME/.m2/settings.xml
fi

echo 'CI環境が作成されました。'
