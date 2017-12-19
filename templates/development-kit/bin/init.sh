#!/bin/bash

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

basedir=$(cd $(dirname $0) && pwd)
cd $basedir

export INTERNAL_FILE_SERVER_URL={{ INTERNAL_FILE_SERVER_URL }}
_command=$1

_setup() {
  # .git がなければ clone する
  if [ ! -e .git ]; then
    git clone git@gitlab.altus-five.com:msatotest2/development-kit.git .
  fi
  # develop ブランチから始める
  if [ $(git branch | grep develop | wc -l) -lt 1 ]; then
    git checkout -b develop origin/develop
  fi
  git checkout develop
  # プロジェクト本体のsubmoduleを更新
  if [ ! -e fuga8/.git ]; then
    git submodule update -i
  fi

  # 開発ツールをセットアップする
  ./bin/setup-devtool.sh

  echo '開発環境のセットアップが完了しました'
}

case "$_command" in
  "" ) _setup ;;
  * )
    echo "unknown command '$_command'"  >&2
    exit 1
    ;;
esac
