#!/bin/bash
# ローカルに開発ツールを準備する
# ./setup-vbox-vagrant.sh

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

_bin_dir=$(cd $(dirname $0) && pwd)
development_kit_dir=$_bin_dir/..

_which_vagrant() {
  _VAGRANT=$(which vagrant 2> /dev/null)
}

cd $development_kit_dir
. ./bin/download-devtool.sh

mkdir -p .tmp
_restart=0

_which_vagrant
if [ "$_VAGRANT" = "" ]; then
  echo "Vagrantのインストール..."
  savepath=$(_download 'vagrant' .tmp)
  echo "Vagrantのインストーラーを起動します。"
  savepath=$(echo $savepath | sed -e 's|/|\\\\|')
  powershell -c "msiexec /i $savepath /passive /norestart | out-null; exit 0"
  _restart=1
  _VAGRANT='/c/HashiCorp/Vagrant/bin/vagrant'
fi

if [ "$VBOX_MSI_INSTALL_PATH" = "" ]; then
  echo "VirtualBoxのインストール..."
  savepath=$(_download 'virtualbox' .tmp)
  echo "VirtualBoxのインストーラーを起動します。"
  currdir=$(powershell -c "pwd")
  currdir=$(echo "$currdir" | tail -1)
  $savepath --extract -path "$currdir\vboxtmp" --silent
  pushd vboxtmp
  msifile=$(ls -1 *amd64.msi)
  popd
  powershell -c "msiexec /i vboxtmp\\$msifile /passive /norestart | out-null; exit 0"
  rm -rf vboxtmp
  _restart=1
fi

installed=$($_VAGRANT plugin list | grep vagrant-vbguest)
if [ "$installed" = "" ]; then
  echo "Vagrantのプラグイン(vagrant-vbguest)をインストールします..."
  $_VAGRANT plugin install vagrant-vbguest
fi

rm -rf .tmp

if [ "$_restart" = "1" ]; then
  echo "VirtualBox / Vagrant がインストールされてました。PCを再起動します。再起動後、同じコマンドを再実行してください。"
  while true ; do
    echo "[Y]es / [N]o"
    read answer
    if [ "$answer" = "Y" ]; then
      break
    elif [ "$answer" = "N" ]; then
      exit 1
    fi
  done
  shutdown -r -t 0
fi
