#!/bin/bash
# プロジェクトの構成を取り込み

__scriptsdir=$(cd $(dirname $BASH_SOURCE) && pwd)

if [ ! -e $__scriptsdir/../.env.sh ]; then
  echo '.env.sh がありません。.env.example.sh をコピーして作成してください。' >&2
  exit 1
fi

. $__scriptsdir/../.env.sh
. $__scriptsdir/lib-gitlab.sh
