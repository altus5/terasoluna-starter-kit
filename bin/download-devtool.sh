#!/bin/bash
# 開発ツールをダウンロードする
# ./download-devtool.sh [directory]
# 引数でダウンロード先を指定すると、そこに対象となるファイルを一括ダウンロードする

declare -A _DOWNLOAD_FILES
export _DOWNLOAD_FILES=(
  # 保存するファイル名がURLで判別するのが、難しい場合は、7z のようにハッシュ以降のsavefile=xxxで指定する
  ["7z"]="https://ja.osdn.net/frs/redir.php?m=jaist&f=%2Fsevenzip%2F64455%2F7za920.zip#savefile=7za920.zip"
  ["maven"]="http://ftp.tsukuba.wide.ad.jp/software/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz"
  ["pleiades"]="http://ftp.jaist.ac.jp/pub/mergedoc/pleiades/4.7/pleiades-4.7.1-java-win-64bit-jre_20171019.zip"
  ["lombok"]="https://projectlombok.org/downloads/lombok.jar"
  ["vagrant"]="https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.msi"
  ["virtualbox"]="http://download.virtualbox.org/virtualbox/5.1.30/VirtualBox-5.1.30-118389-Win.exe"
)

_download() {
  key=$1
  savedir=$2
  url=${_DOWNLOAD_FILES[$key]}
  savefile=$(basename $url)
  repl=$(echo $savefile | sed -e 's/.*#savefile=\(.*\)/\1/')
  if [ "$repl" != "" ]; then
    savefile=$repl
  fi
  if [ "$INTERNAL_FILE_SERVER_URL" != "" ]; then
    url=$INTERNAL_FILE_SERVER_URL/$savefile
  fi
  mkdir -p $savedir
  echo "$url -> $savedir/$savefile" 1>&2
  curl -L $url > $savedir/$savefile
  echo $savedir/$savefile
}

if [ "$1" != "" ]; then
  set -e
  trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

  mkdir -p $1
  for _file in ${!_DOWNLOAD_FILES[@]};
  do
    echo $_file
    _download $_file $1
  done
fi

