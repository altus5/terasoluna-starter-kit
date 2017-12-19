__basedir=$(cd $(dirname $BASH_SOURCE) && pwd)
__rootdir=$__basedir/..
export JAVA_HOME=$__rootdir/java/8
export M2_HOME=$__rootdir/maven
export PATH=$M2_HOME/bin:$JAVA_HOME/bin:$PATH
