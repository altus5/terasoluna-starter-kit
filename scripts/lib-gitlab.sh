#!/bin/bash
# Gitlabへのプロジェクトの登録や、cloneを行う
# ./lib-gitlab.sh

set -e
trap 'echo "ERROR $0 ($LINENO)" 1>&2' ERR

_usage_env() {
  envname=$1
  cat <<EOF >&2
  環境変数 $envname が設定されていません。
  詳しくは、こちらを参照してください。
  https://github.com/altus5/terasoluna-starter-kit#enviroment
EOF
  exit 1
}

_gitlab_create_group() {
  [ "$PROJECT_GROUP" = "" ] && _usage_env PROJECT_GROUP
  [ "$GITLAB_PRIVATE_TOKEN" = "" ] && _usage_env GITLAB_PRIVATE_TOKEN
  exists=$(
    curl -sSL --request GET \
      --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
      "$GITLAB_URL/api/v3/groups?search=$PROJECT_GROUP" \
      | grep $PROJECT_GROUP | wc -l
  )
  if [ "$exists" = "0" ]; then
    echo "create gitlab group ..."
    curl -sSL --request POST \
      --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
      --data "name=$PROJECT_GROUP" \
      --data "path=$PROJECT_GROUP" \
      --data "visibility=private" \
      $GITLAB_URL/api/v3/groups >& /dev/null
  fi
  PROJECT_GROUP_ID=$(
    curl -sSL --request GET \
      --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
      "$GITLAB_URL/api/v3/groups?search=$PROJECT_GROUP" \
      | sed -e 's/.*"id":\([0-9]\+\).*/\1/'
  )
}
_url_encode() {
  param=$1
  perl -MURI::Escape -e "print uri_escape('$param');"
}
_create_gitlab_project() {
  [ "$PROJECT_GROUP" = "" ] && _usage_env PROJECT_GROUP
  [ "$GITLAB_PRIVATE_TOKEN" = "" ] && _usage_env GITLAB_PRIVATE_TOKEN
  [ "$PROJECT_GROUP_ID" = "" ] && _usage_env PROJECT_GROUP_ID
  _project_name=$1
  exists=$(
    curl -sSL --request GET \
      --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
      $GITLAB_URL/api/v3/projects/$(_url_encode $PROJECT_GROUP/$_project_name) \
      | grep $PROJECT_GROUP/$_project_name | wc -l
  )
  if [ "$exists" = "0" ]; then
    echo "create gitlab project ..."
    curl -sSL --request POST \
      --header "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
      --data "name=$_project_name" \
      --data "path=$_project_name" \
      --data "namespace_id=$PROJECT_GROUP_ID" \
      $GITLAB_URL/api/v3/projects
  fi
}

GITLAB_HOST=`echo $GITLAB_URL | sed -e 's|.*\?//\([^:/]\+\).*|\1|'`

_gitlab_repository_url() {
  _project_name=$1
  echo "git@$GITLAB_HOST:$PROJECT_GROUP/$_project_name.git"
}

_gitlab_init() {
  _project_name=$1
  _subdir=${2:-$_project_name}
  [ "$_project_name" = "" ] && _usage_env '$1'
  [ "$_subdir" = "" ] && _usage_env '$2'
  if [ -e $_subdir/.git ]; then
    return 0
  fi
  _gitlab_create_group

  [ "$GITLAB_URL" = "" ] && _usage_env 'GITLAB_URL'
  pushd $_subdir
  _create_gitlab_project $_project_name
  git init
  git remote add origin $(_gitlab_repository_url $_project_name)
  git add .
  git commit -m "first commit"
  popd
}

_gitlab_init_and_push() {
  _gitlab_init $1 $2
  pushd $_subdir
  git push -u origin master
  git checkout -b develop
  git push -u origin develop
  popd
}

_gitlab_clone() {
  _project_name=$1
  _subdir=${2:-$_project_name}
  [ "$_project_name" = "" ] && _usage_env '$1'
  [ "$_subdir" = "" ] && _usage_env '$2'
  if [ -e $_subdir/.git ]; then
    return 0
  fi
  [ "$PROJECT_GROUP" = "" ] && _usage_env PROJECT_GROUP
  [ "$GITLAB_URL" = "" ] && _usage_env GITLAB_URL
  pushd $_subdir
  git clone $(_gitlab_repository_url $_project_name) .
  git checkout -b develop origin/develop
  popd
}

