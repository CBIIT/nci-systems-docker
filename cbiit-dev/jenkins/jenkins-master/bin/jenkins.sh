#! /bin/bash -e
##
 # This script will start up a jenkins instance in free-standing mode.
 # If JENKINS_HOME does not exist, then it will populate it from the 
 # reference directory.
 # WARNING: If reinitializing (JENKINS_REINSTALL non-blank), then JENKINS_HOME 
 # will be wiped out and repopulated!!
 #
 # args:
 #    1   : <blank> or '--', then run jenkins, otherwise run 'exec' with the 
 #          given parameter
 #    ... : Additional parameters to pass to 'exec'
 ##
[ -n "$DEBUG" ] && set -x -v && id && set|sort

set -o pipefail

#set defaults
: "${BIN_DIR:="/usr/local/bin"}"
: "${REF_DIR:="/usr/share/ref/jenkins"}"
: "${JENKINS_HOME:="/var/lib/jenkins"}"
: "${JENKINS_JAVA_CMD:=""}"
: "${JENKINS_INSTALL_SKIP_CHOWN:="false"}"
: "${JENKINS_JAVA_OPTIONS:="-Djava.awt.headless:=true"}"
: "${JENKINS_PORT:="8080"}"
: "${JENKINS_LISTEN_ADDRESS:=""}"
: "${JENKINS_HTTPS_PORT:=""}"
: "${JENKINS_HTTPS_KEYSTORE:=""}"
: "${JENKINS_HTTPS_KEYSTORE_PASSWORD:=""}"
: "${JENKINS_HTTPS_LISTEN_ADDRESS:=""}"
: "${JENKINS_DEBUG_LEVEL:="5"}"
: "${JENKINS_ENABLE_ACCESS_LOG:="no"}"
: "${JENKINS_HANDLER_MAX:="100"}"
: "${JENKINS_HANDLER_IDLE:="20"}"
: "${JENKINS_ARGS:=""}"
: "${JENKINS_REINSTALL:=""}" #if non-blank, then reinstall configuration
: "${JENKINS_JNLP_PORT:="-1"}"
: "${JENKINS_WAR:="$JENKINS_HOME/lib/jenkins.war"}"
: "${JENKINS_WEB_ROOT:="/var/lib/jenkins/war"}"
: "${JENKINS_UC:=""}"

# if `docker run` first argument start with `--`, the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then

  base=$(basename "$JENKINS_WAR") || exit $?

  #validate reference resources
  [ ! -d $REF_DIR ] && { echo "FATAL: Reference directory '$REF_DIR' not found."; exit 1; }
  [ -n "$JENKINS_REINSTALL" -a ! -f $REF_DIR/lib/$base ] \
    && { echo "FATAL: Jenkins WAR not found in '$REF_DIR/lib/$base'."; exit 1; }

  #reinstall reference files in workspace, if needed
  if [ -n "$JENKINS_REINSTALL" -a -d $REF_DIR ] || [ ! -d $JENKINS_HOME -a -d $REF_DIR ]; then 
    echo "Copy reference files..."
    rsync -avzh --delete $REF_DIR/ $JENKINS_HOME/ || exit $?
    echo "Copy reference files...OK"
  fi

  #validate workspace resources
  [ ! -f $JENKINS_WAR ] && { echo "FATAL: Jenkins WAR not found in '$JENKINS_WAR'."; exit 1; }
  [ ! -d $JENKINS_HOME/log ] && { echo "FATAL: Jenkins log directory not found in '$JENKINS_HOME/log'."; exit 1; }
    
  #determine command line
  #  java options and system properties
  JAVA_CMD="$JENKINS_JAVA_CMD $JENKINS_JAVA_OPTIONS -DJENKINS_HOME=$JENKINS_HOME"
  [ -n "$JENKINS_REINSTALL" ] && JAVA_CMD="$JAVA_CMD -DJENKINS_REINSTALL=$JENKINS_REINSTALL"
  [ -n "$JENKINS_JNLP_PORT" ] && JAVA_CMD="$JAVA_CMD -DJENKINS_JNLP_PORT=$JENKINS_JNLP_PORT"
  [ -n "$JENKINS_UC" ] && JAVA_CMD="$JAVA_CMD -DJENKINS_UC=$JENKINS_UC"
  JAVA_CMD="$JAVA_CMD -jar $JENKINS_WAR"
  #  jenkins parameters
  PARAMS="--logfile=$JENKINS_HOME/log/jenkins.log --webroot=$JENKINS_WEB_ROOT"
  [ -n "$JENKINS_PORT" ] && PARAMS="$PARAMS --httpPort=$JENKINS_PORT"
  [ -n "$JENKINS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpListenAddress=$JENKINS_LISTEN_ADDRESS"
  [ -n "$JENKINS_HTTPS_PORT" ] && PARAMS="$PARAMS --httpsPort=$JENKINS_HTTPS_PORT"
  [ -n "$JENKINS_HTTPS_KEYSTORE" ] && PARAMS="$PARAMS --httpsKeyStore=$JENKINS_HTTPS_KEYSTORE"
  [ -n "$JENKINS_HTTPS_KEYSTORE_PASSWORD" ] && PARAMS="$PARAMS --httpsKeyStorePassword='$JENKINS_HTTPS_KEYSTORE_PASSWORD'"
  [ -n "$JENKINS_HTTPS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpsListenAddress=$JENKINS_HTTPS_LISTEN_ADDRESS"
  [ -n "$JENKINS_DEBUG_LEVEL" ] && PARAMS="$PARAMS --debug=$JENKINS_DEBUG_LEVEL"
  [ -n "$JENKINS_HANDLER_STARTUP" ] && PARAMS="$PARAMS --handlerCountStartup=$JENKINS_HANDLER_STARTUP"
  [ -n "$JENKINS_HANDLER_MAX" ] && PARAMS="$PARAMS --handlerCountMax=$JENKINS_HANDLER_MAX"
  [ -n "$JENKINS_HANDLER_IDLE" ] && PARAMS="$PARAMS --handlerCountMaxIdle=$JENKINS_HANDLER_IDLE"
  [ -n "$JENKINS_ARGS" ] && PARAMS="$PARAMS $JENKINS_ARGS"
  if [ "$JENKINS_ENABLE_ACCESS_LOG" = "yes" ]; then
    PARAMS="$PARAMS --accessLoggerClassName=winstone.accesslog.SimpleAccessLogger 
      --simpleAccessLogger.format=combined --simpleAccessLogger.file=$JENKINS_HOME/log/access.log"
  fi

  #run jenkins
  echo "exec $JAVA_CMD $PARAMS $@"
  exec $JAVA_CMD $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"
