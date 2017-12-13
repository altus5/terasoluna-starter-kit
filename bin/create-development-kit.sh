#!/bin/bash

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

basedir=$(cd $(dirname $0) && pwd)
rootdir=$basedir/..
cd $rootdir


# プロジェクトの構成を取り込み
. ./bin/config.sh

# 開発チームに配布する開発キットを作成する
./bin/render-templates.sh ./templates ./$DEVELOPMENT_KIT_NAME
cp ./bin/download-devtool.sh ./$DEVELOPMENT_KIT_NAME/bin
cp ./bin/setup-vbox-vagrant.sh ./$DEVELOPMENT_KIT_NAME/bin

# TERASOLUNAのブランクプロジェクトを作成するために
# starter-kitを使って開発ツールをインストールする
./$DEVELOPMENT_KIT_NAME/bin/setup-devtool.sh

# starter-kitのリポジトリをプッシュする
pushd ./$DEVELOPMENT_KIT_NAME
## starter-kitのリポジトリを作成
_gitlab_init_and_push $DEVELOPMENT_KIT_NAME .

## terasolunaのブランクプロジェクトを作成してプッシュする
. ./bin/setenv.sh
$rootdir/bin/setup-terasoluna.sh
_gitlab_init_and_push $PROJECT_NAME

## ブランクプロジェクトをstarter-kitのsubmoduleにする
git submodule add $PROJECT_REPO_URL $PROJECT_NAME
git add .gitmodules
git commit -m "Add $PROJECT_NAME as a submodule"
git push

git checkout master
git merge develop
git push
git checkout develop

popd

echo '開発チームに配布する開発キットが作成されました。'
