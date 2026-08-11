#! /bin/sh

git clone  --depth=1 https://github.com/wikimedia/mediawiki-tools-mwdumper mwdumper
cd mwdumper

# fix: [ERROR] Plugin org.apache.maven.plugins:maven-resources-plugin:3.3.0 or one of its dependencies could not be resolved: The following artifacts could not be resolved: org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 (absent): Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven.plugins:maven-resources-plugin:jar:3.3.0 has not been downloaded from it before. -> [Help 1]
# https://stackoverflow.com/questions/12533885/could-not-calculate-build-plan-plugin-org-apache-maven-pluginsmaven-resources
patch -p1 <../0001-add-maven-resources-plugin-3.3.0.patch

# fix: [ERROR] error: Source option 6 is no longer supported. Use 7 or later.
# fix: [ERROR] error: Target option 6 is no longer supported. Use 7 or later.
# https://stackoverflow.com/questions/61860989/another-maven-source-option-6-is-no-longer-supported-use-7-or-later
patch -p1 <../0002-update-source-and-target-version.patch

# update dependencies
# https://www.baeldung.com/maven-dependency-latest-version
mvn versions:use-latest-releases
cp pom.xml ../pom.xml

# https://github.com/fzakaria/mvn2nix
nix run github:fzakaria/mvn2nix#mvn2nix >../mvn2nix-lock.json
