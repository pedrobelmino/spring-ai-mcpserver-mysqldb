#!/bin/sh
#
# Copyright 2021 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

#
# Resolve the location of the MAVEN_HOME.
#
# If MAVEN_HOME is not set, then the value of the --maven-home command line
# argument is used. If the --maven-home is not specified, then the value
# of the mvnw script's directory is used.
#
# The MAVEN_HOME is exported as an environment variable so that it can be
# correctly resolved by any forked Maven processes.
#
MAVEN_HOME=
for arg in "$@"; do
  case "$arg" in
    --maven-home=*)
      MAVEN_HOME="${arg#*=}"
      ;;
  esac
done
if [ -z "$MAVEN_HOME" ]; then
  MAVEN_HOME="$( cd "$( dirname "$0" )" && pwd )"
fi
export MAVEN_HOME

#
# Resolve the location of the MAVEN_PROJECT_HOME.
#
# The MAVEN_PROJECT_HOME is the project's top-level directory and is used as
# the base directory for the execution of the Maven build. It is assumed to be
# the user's current working directory.
#
# The MAVEN_PROJECT_HOME is exported as an environment variable so that it
# can be correctly resolved by any forked Maven processes.
#
MAVEN_PROJECT_HOME="$(pwd)"
export MAVEN_PROJECT_HOME

#
# Execute the Takari extensions.
#
# The Takari extensions are downloaded and executed. The Takari extensions are
# responsible for downloading and executing the Maven distribution.
#
MAVEN_REPO_LOCAL=
for arg in "$@"; do
  case "$arg" in
    -Dmaven.repo.local=*) 
      MAVEN_REPO_LOCAL="${arg#*=}"
      ;;
  esac
done
if [ -z "$MAVEN_REPO_LOCAL" ]; then
  MAVEN_REPO_LOCAL="$HOME/.m2/repository"
fi

main () {
  MAVEN_LAUNCHER_JAR="$MAVEN_HOME/.mvn/wrapper/maven-wrapper.jar"

  if [ ! -f "$MAVEN_LAUNCHER_JAR" ]; then
    MAVEN_WRAPPER_JAR="$MAVEN_HOME/.mvn/wrapper/maven-wrapper.jar"
    if [ ! -f "$MAVEN_WRAPPER_JAR" ]; then
      MAVEN_WRAPPER_PROPERTIES="$MAVEN_HOME/.mvn/wrapper/maven-wrapper.properties"
      if [ -f "$MAVEN_WRAPPER_PROPERTIES" ]; then
        MAVEN_WRAPPER_URL=
        while IFS='=' read -r key value; do
          case "$key" in
            wrapperUrl) MAVEN_WRAPPER_URL="$value" ;;
          esac
        done < "$MAVEN_WRAPPER_PROPERTIES"
        if [ -n "$MAVEN_WRAPPER_URL" ]; then
          mkdir -p "$(dirname "$MAVEN_WRAPPER_JAR")"
          echo "Downloading $MAVEN_WRAPPER_URL to $MAVEN_WRAPPER_JAR"
          download "$MAVEN_WRAPPER_URL" "$MAVEN_WRAPPER_JAR"
        fi
      fi
    fi
  fi

  exec "$JAVACMD" \
    -classpath "$MAVEN_LAUNCHER_JAR" \
    "-Dmaven.home=$MAVEN_HOME" \
    "-Dmaven.project.home.directory=$MAVEN_PROJECT_HOME" \
    "-Dmaven.multiModuleProjectDirectory=$MAVEN_PROJECT_HOME" \
    org.apache.maven.wrapper.MavenWrapperMain "$@"
}

#
# Download a file from a URL.
#
# This function is used to download the Takari extensions and the Maven
# distribution if they are not already present in the user's local Maven
# repository.
#
download () {
  if command -v curl > /dev/null; then
    curl -fL "$1" -o "$2"
  elif command -v wget > /dev/null; then
    wget "$1" -O "$2"
  else
    echo "Neither curl nor wget is available. Please install one of them."
    exit 1
  fi
}

#
# Find the Java command.
#
# This function is used to find the Java command. If the JAVA_HOME environment
# variable is set, then the Java command is resolved from the JAVA_HOME.
# Otherwise, the Java command is resolved from the system's PATH.
#
find_java () {
  if [ -n "$JAVA_HOME" ]; then
    if [ -x "$JAVA_HOME/bin/java" ]; then
      JAVACMD="$JAVA_HOME/bin/java"
    else
      echo "The JAVA_HOME environment variable is set but the Java command is not executable."
      exit 1
    fi
  else
    JAVACMD=java
    if ! command -v JAVACMD > /dev/null; then
      echo "The JAVA_HOME environment variable is not set and the Java command is not in the system's PATH."
      exit 1
    fi
  fi
}

find_java
main "$@"