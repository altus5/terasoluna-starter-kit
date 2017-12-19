#!/bin/bash
# ./render-template.sh srcdir dstdir

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

srcdir=$1
dstdir=$2

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

echo '' > _tmpsed
for envvar in "${_ENV_VARS[@]}"
do
  value=$(eval "echo \$$envvar")
  value=$(echo $value | sed -e 's/\(\[\|]\|[\(\)\+\?\|\$\.\*\\\^\/]\)/\\\1/g')
  echo "s/{{ *$envvar *}}/$value/g" >> _tmpsed
done

_replace_text() {
  text=$1
  text=$(echo "$text" | sed -f _tmpsed)
  echo "$text"
}

_replace_file() {
  file=$1
  sed -i -f _tmpsed $file
}

_render() {
  src=$1
  dst=$2
  mkdir -p $(dirname $dst)
  cp $src $dst
  _replace_file $dst
}

if [ -d $srcdir ]; then
  for srcfile in $(find $srcdir -type f)
  do
    dstfile=$(echo $srcfile | sed -e "s|$srcdir||")
    dstfile=$(_replace_text $dstfile)
    _render $srcfile $dstdir$dstfile
  done
else
  srcfile=$srcdir
  _render $srcfile $dstdir/$(basename $srcfile)
fi

rm _tmpsed