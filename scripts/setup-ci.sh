#!/bin/bash
# ./setup-ci.sh

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

basedir=$(cd $(dirname $0) && pwd)
rootdir=$basedir/..
cd $rootdir

if [ ! -e .env.sh ]; then
  echo '.env.sh がありません。.env.example.sh をコピーして作成してください。' >&2
  exit 1
fi
. .env.sh

# virtualboxとvagrantをインストールする
./scripts/setup-vbox-vagrant.sh

# vagrantでansibleを実行する
vagrant up
vagrant ssh -c "cd /vagrant/ansible && ansible-playbook -i inventories/build build-servers.yml"

# .m2/settings.xml を作成する
./scripts/render-templates.sh ./m2/settings.xml .
_repl_m2_settings=1
if [ -e $HOME/.m2/settings.xml ]; then
  md5new=`md5sum settings.xml | awk '{ print $1 }'`
  md5old=`md5sum $HOME/.m2/settings.xml | awk '{ print $1 }'`
  if [ "$md5new" = "$md5old" ]; then
    _repl_m2_settings=0
  else
    cp -p $HOME/.m2/settings.xml $HOME/.m2/settings.xml.bk
    echo '[注意] $HOME/.m2/settings.xml を作成しました。既存のファイルは、 $HOME/.m2/settings.xml.bk として退避しました。'
  fi
fi
if [ "$_repl_m2_settings" = "1" ]; then
  mv -f settings.xml $HOME/.m2/settings.xml
fi

echo 'CI環境が作成されました。'
