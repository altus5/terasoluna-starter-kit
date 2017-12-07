#!/bin/bash
# ローカルに開発ツールを準備する
# ./setup-devtool.sh

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

_bin_dir=$(cd $(dirname $0) && pwd)
cd $_bin_dir/..

. ./bin/download-devtool.sh

mkdir -p .tmp

if [ ! -e maven ]; then
  echo 'mavenのインストール...'
  savepath=$(_download 'maven' .tmp)
  tar xvfz $savepath
  untardir=$(basename $savepath | sed -e 's/-bin.tar.gz$//')
  mv $untardir maven
fi

if [ ! -e eclipse ]; then
  echo '7zの取得（pleiadesの解凍用）...'
  savepath=$(_download '7z' .tmp)
  pushd .tmp
  unzip $(basename $savepath)
  popd

  echo 'pleiadesのインストール...'
  savepath=$(_download 'pleiades' .tmp)
  .tmp/7za.exe x $savepath
  mv pleiades/* .
  mv pleiades/.metadata.default .
  rm -rf pleiades*

  echo 'lombokのインストール...'
  savepath=$(_download 'lombok' .tmp)
  . ./bin/setenv.sh
  java -jar $savepath install ./eclipse
fi

rm -rf .tmp

./bin/setup-vbox-vagrant.sh
