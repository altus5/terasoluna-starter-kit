#!/bin/bash
# ./render-template.sh srcdir dstdir

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

_ENV_VARS=(
  'GITLAB_URL'
  'GITLAB_PRIVATE_TOKEN'
  'PROJECT_GROUP'
  'PROJECT_NAME'
  'POM_GROUP_ID'
  'TERASOLUNA_ARTIFACT_ID'
  'TERASOLUNA_VERSION'
  'NEXUS_HOST'
  'NEXUS_PORT'
  'NEXUS_DEPLOYMENT_EMAIL'
  'JENKINS_HOST'
  'JENKINS_PORT'
  'JENKINS_USER_EMAIL'
  'JENKINS_PRIVATE_TOKEN'
  
  'DEVELOPMENT_KIT_REPO_URL'
  'PROJECT_REPO_URL'
)

_render() {
  src=$1
  dst=$2
  mkdir -p $(dirname $dst)
  text=$(cat $src)
  for envvar in "${_ENV_VARS[@]}"
  do
    value=$(eval "echo \$$envvar")
    value=$(echo $value | sed -e 's/\(\[\|]\|[\(\)\+\?\|\$\.\*\\\^\/]\)/\\\1/g')
    text=$(echo "$text" | sed -e "s/{{ *$envvar *}}/$value/g")
  done
  echo "$text" > $dst
}

srcdir=$1
dstdir=$2

if [ -d $srcdir ]; then
  for srcfile in $(find $srcdir -type f)
  do
    dstfile=$(echo $srcfile | sed -e "s|$srcdir||")
    _render $srcfile $dstdir$dstfile
  done
else
  srcfile=$srcdir
  _render $srcfile $dstdir/$(basename $srcfile)
fi

