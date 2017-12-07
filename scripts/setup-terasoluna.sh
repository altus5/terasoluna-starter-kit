#!/bin/bash
# terasolunaのブランクプロジェクトを作成する
# setup-terasoluna.sh

if [ "$PROJECT_NAME" = "" ]; then
  echo '環境変数 PROJECT_NAME が設定されていません。' >&2
  exit 1
fi
if [ "$POM_GROUP_ID" = "" ]; then
  echo '環境変数 POM_GROUP_ID が設定されていません。' >&2
  exit 1
fi

# 作成済の場合は何もしない
if [ -e $PROJECT_NAME ]; then
  exit 0
fi

# archetypeIdとversionの指定がない場合のデフォルト設定
TERASOLUNA_ARTIFACT_ID=${TERASOLUNA_ARTIFACT_ID:-mybatis3}
TERASOLUNA_VERSION=${TERASOLUNA_VERSION:-5.3.1.RELEASE}

echo "generate terasoluna blank project ..."

mvn archetype:generate -B \
 -DarchetypeGroupId=org.terasoluna.gfw.blank \
 -DarchetypeArtifactId=terasoluna-gfw-multi-web-blank-${TERASOLUNA_ARTIFACT_ID}-archetype \
 -DarchetypeVersion=$TERASOLUNA_VERSION \
 -DgroupId=$POM_GROUP_ID \
 -DartifactId=$PROJECT_NAME \
 -Dversion=1.0.0-SNAPSHOT
