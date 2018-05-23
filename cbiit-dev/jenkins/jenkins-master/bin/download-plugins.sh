#! /bin/bash -e
##
 # This script will download the given versions of the plugins listed in the given file 
 # to the reference directory. It assumes the reference directory is empty.
 #
 # WARNING: This script does not check plugin dependencies!!
 #
 # Plugins file format: <name>:<version> (version may be 'latest' or <blank>, comment lines begin 
 # with '#' and will be ignored; blank lines will be ignored)
 #
 # @author Phil Hartman <phil.hartman@nih.gov>
 ## 
#NOTE: takes about 2-10 min to run depending on download speed

[ -n "$DEBUG" ] && set -x -v && id && set|sort

set -o pipefail

#set defaults
: "${REF_DIR:="/usr/share/ref/jenkins"}"
: "${JENKINS_UC:="http://updates.jenkins.io"}"
: "${JENKINS_REINSTALL:=""}"
: "${PLUGINS_FILE:="$(dirname "$0")/plugins.txt"}"

#if not reinstalling, then exit
if [ -z "JENKINS_REINSTALL" ]; then
  echo "Download plugins...SKIPPED. JENKINS_REINSTALL is blank"
  exit 0
fi

#if plugins file not found, then exit
if [ -z "$PLUGINS_FILE" ] || [ ! -f "$PLUGINS_FILE" ]; then 
  echo "Download plugins...SKIPPED. Plugins file '$PLUGINS_FILE' not found"
  exit 0
fi

#make plugins directory
if [ ! -d "$REF_DIR/plugins" ]; then mkdir -p $REF_DIR/plugins || exit $?; fi

#download plugins
echo "Download plugins (may take a while)..."
total="$(grep -P '(?!^\s*($|#))' $PLUGINS_FILE|wc -l)" || exit $?
i=0
while read spec; do
    plugin=(${spec//:/ });
    [[ ${plugin[0]} =~ ^\s*# ]] && continue #skip comments
    [[ ${plugin[0]} =~ ^\s*$ ]] && continue #skip blank lines
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"
    echo "Download ${plugin[0]}:${plugin[1]} ($(((i+1))) of $total)..."
    (
      curl -fsSL ${JENKINS_UC}/download/plugins/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi -o $REF_DIR/plugins/${plugin[0]}.jpi || exit $?
      #verify download
      unzip -qqt $REF_DIR/plugins/${plugin[0]}.jpi || exit $?
    ) &
    #TODO: why does ((i++)) not work??
    ((i=i+1))
done < $PLUGINS_FILE
wait
echo "OK"
