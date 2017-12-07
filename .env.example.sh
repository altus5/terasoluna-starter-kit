# GitlabのURL
export GITLAB_URL=https://gitlab.local
# リポジトリオーナーの Private Token
export GITLAB_PRIVATE_TOKEN=XxxxxXXXssss
# リポジトリのグループ名
export PROJECT_GROUP=myproject
# リポジトリのプロジェクト名
export PROJECT_NAME=example-crm
# pom.xmlのgroupId
export POM_GROUP_ID=jp.example
# TERASOLUNAのarchetypeArtifactId ( mybatis3 | jpa が選択可能 )
export TERASOLUNA_ARTIFACT_ID=mybatis3
# TERASOLUNAのバージョン
export TERASOLUNA_VERSION=5.3.1.RELEASE

# 開発ツールのダウンロード元(社内のファイルサーバーに保存してある場合など)
#export INTERNAL_FILE_SERVER_URL=file:///Users/hoge/projects/download
export INTERNAL_FILE_SERVER_URL=file:////192.168.1.100/Public/download

# nexus関連の設定
## Nexusのホストを"IPアドレス"で指定
export NEXUS_HOST=192.168.1.10
export NEXUS_PORT=18081
export NEXUS_DEPLOYMENT_EMAIL=myproject-ml@example.jp

# jenkins関連の設定
## Jenkinsのホストを"IPアドレス"で指定
export JENKINS_HOST=192.168.1.10
export JENKINS_PORT=18080
export JENKINS_USER_EMAIL=myproject-ml@example.jp
export JENKINS_PRIVATE_TOKEN=YyyyyyZZDndakh
