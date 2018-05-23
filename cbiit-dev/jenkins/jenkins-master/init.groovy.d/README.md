This directory contains groovy scripts that will be run on Jenkins startup after plugins are loaded. 
Scripts will be processed in lexigraphical order by file name.
See https://wiki.jenkins.io/display/JENKINS/Groovy+Hook+Script for more details.
Note: Groovy script names cannot begin with a number.

Default scripts are located in https://github.com/cbiit/nci-systems-devops/jenkins/_common/init.groovy.d