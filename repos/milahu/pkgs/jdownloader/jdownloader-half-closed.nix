# draft...

# building jdownloader from source fails
# because the "JDClosed/src" part of jdownloader is not "open source"

# TODO https://ryantm.github.io/nixpkgs/languages-frameworks/maven/

/*
cd project/

mvn org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix  # -> project-info.json

# default.nix
{ pkgs ? import <nixpkgs> { } }:
pkgs.buildMaven ./project-info.json).build

*/

/* MAINTAIN
running eclipse-headless did not work,
so i loaded the projects in eclipse:

mkdir src
cd src
urls=$(
cat <<EOF
https://github.com/mirror/jdownloader
https://github.com/milahu/appwork-utils
https://github.com/milahu/jdownloader-browser
https://github.com/milahu/jdownloader-client
EOF
)
for u in $urls; do
  git clone --depth 1 $u
done

file > open projects from filesystem
> select parent directory (src/)
then:
JDownloader > rightclick > export > java > runnable jar file > next
launch config: JDLauncher - JDownloader
export dest: src/JDownloader.jar
lib handling: copy
save ant script: yes
ant script location: src/build-jar.xml
finish

sed -i 's|JDownloader_libs/||; s|/nix/store/.{32}-eclipse-java-[.0-9]+|${dir.jarfile}|' build-jar.xml

so that all *.jar files are in the same folder
so that eclipse jars are in src/eclipse:
eclipse/plugins/org.junit_4.13.0.v20200204-1500.jar
eclipse/plugins/org.hamcrest.core_1.3.0.v20180420-1519.jar





JDownloader > rightclick > export > general > ant buildfiles > next
select all projects
compile projects using eclipse compiler: no
finish

launch config: JDLauncher - JDownloader
export dest: src/JDownloader.jar
lib handling: copy
save ant script: yes
ant script location: src/build-jar.xml
finish


*/

{ stdenv
, lib
, fetchurl
, fetchFromGitHub
, writeScript
, writeShellScript
, makeDesktopItem
, copyDesktopItems
, jre
, jdk
, ant
, imagemagick
, coreutils
, jdownloaderAutoUpdate ? false
, subversion
, makeWrapper
, bash
, eclipses
, xmlstarlet, diffutils
, cacert # required by subversion TODO should be a dependency of subversion
}:

let

  icon = fetchurl {
    url = "https://jdownloader.org/_media/vote/trazo.png";
    sha256 = "3ebab992e7dd04ffcb6c30fee1a7e2b43f3537cb2b22124b30325d25bffdac29";
  };

  #  PATH=$PATH:${lib.makeBinPath [ jre coreutils ]}

  # the official repos are svn, so fetch-by-commit is not-yet implemented in nix
  # svn repos are mirrored to github with https://github.com/milahu/svn2github

  # sources
  # https://support.jdownloader.org/Knowledgebase/Article/View/setup-ide-eclipse

  /*
    svn://svn.appwork.org/utils
    svn://svn.jdownloader.org/jdownloader/browser
    svn://svn.jdownloader.org/jdownloader/trunk
    svn://svn.jdownloader.org/jdownloader/MyJDownloaderClient
  */

  sources = {
    eclipse = "${eclipses.eclipse-java}/eclipse";

    jdownloader = fetchFromGitHub rec {
      # the official repo is password-protected # TODO what??
      name = repo;
      owner = "mirror";
      repo = "jdownloader";
      rev = "e07d1cafcdfd22939e38b76ff334ce9a937cf0d4";
      sha256 = "03vss65j62cai010ibzaykn5xlj9kyg9vwwywndbfrygqxjah11i";
    };

    appwork-utils = fetchFromGitHub rec {
      name = repo;
      owner = "milahu";
      repo = "appwork-utils";
      rev = "23f8ea5abe37f2760c6193cb2f50e749e12f434f";
      sha256 = "1r87w1h7al3sr6bir1nv8nxw12r1cg3351xvaypxw1vs58xngfaq";
    };

    jdownloader-client = fetchFromGitHub rec {
      name = repo;
      owner = "milahu";
      repo = "jdownloader-client";
      rev = "08d15d9678f2b246d82c896a27cdf0f675ea6c65";
      sha256 = "10za6swks0vzy07nllhn5asfrdh56zpi17g4cwdwy15wig3dib3v";
    };

    jdownloader-browser = fetchFromGitHub rec {
      name = repo;
      owner = "milahu";
      repo = "jdownloader-browser";
      rev = "bd85d2fe215bebf0f1cb274439c42149a230ad02";
      sha256 = "15pdrv4p6pxsa0bwins5m85dmkjzsrhgd3wqdj32m0qlrylijm9d";
    };
  };

in

/*
nativeBuildInputs = [ makeWrapper ];

installPhase = ''
  mkdir -p $out/bin
  makeWrapper ${jre}/bin/java $out/bin/foo \
    --add-flags "-cp $out/share/java/foo.jar org.foo.Main"
'';
*/

stdenv.mkDerivation rec {
  pname = "jdownloader";
  version = "2021-09-30";

  #src = ./src;
  #srcs = sources; # TODO must be list
  srcs = lib.mapAttrsToList (name: value: value) sources;
  #sourceRoot = pname;
  sourceRoot = "."; # cwd == /build

  # based on https://jdownloader.org/knowledge/wiki/development/get-started

  # https://nixos.org/manual/nixpkgs/stable/#sec-language-java
  # JAR files that are intended to be used by other packages
  # should be installed in $out/share/java.
  # JDKs have a stdenv setup hook that
  # add any JARs in the share/java directories of the build inputs
  # to the CLASSPATH environment variable.

  #  ln -s ${eclipses.eclipse-java}/eclipse/plugins/org.junit_4.13.0.v20200204-1500.jar .
  #  ln -s ${eclipses.eclipse-java}/eclipse/plugins/org.hamcrest.core_1.3.0.v20180420-1519.jar .
#    ${lib.mapAttrsToList (name: value: ''ln -s ${value} ${name}'') sources}

  # eclipse can build jd, but ant throws:
  # jdownloader/build.xml:189: JDClosed/src does not exist.
  # -> remove JDClosed from jdownloader/build.xml
  /*
Compiling 4610 source files to /build/jdownloader/bin
/build/jdownloader/src/jd/plugins/AccountInfo.java:267: error: cannot find symbol
        final long serverTime = br.getCurrentServerTime(-1);
                                  ^
  symbol:   method getCurrentServerTime(int)
  location: variable br of type Browser
  */

  buildPhase = ''
    echo "jdownloader buildPhase"
    set -o xtrace

    ln -s ${./src/appwork-utils/build.xml} appwork-utils/build.xml
    ln -s ${./src/jdownloader-browser/build.xml} jdownloader-browser/build.xml
    ln -s ${./src/jdownloader-client/build.xml} jdownloader-client/build.xml
    ln -s ${./src/jdownloader/build.xml} jdownloader/build.xml

    for buildFile in */build.xml
    do
      # error: Source option 6 is no longer supported. Use 7 or later.
      # error: Target option 6 is no longer supported. Use 7 or later.
      sed -i 's|<property name="source" value="1.6"/>|<property name="source" value="1.7"/>|' $buildFile
      sed -i 's|<property name="target" value="1.6"/>|<property name="target" value="1.7"/>|' $buildFile

      # set charset
      sed -i 's|</javac>|<compilerarg line="-encoding latin1"/></javac>|' $buildFile

      # hide warnings, except proprietary API warnings https://stackoverflow.com/questions/9613857
      sed -i 's|<javac |<javac nowarn="on" |' $buildFile
    done

    # no effect
    echo "hide 'proprietary API' warnings"
    sed -i.orig 's|public class OracleWorkaroundJarHandler|@SuppressWarnings("sunapi")\npublic class OracleWorkaroundJarHandler|' appwork-utils/src/org/appwork/utils/OracleWorkaroundJarHandler.java
    diff -u appwork-utils/src/org/appwork/utils/OracleWorkaroundJarHandler.java{.orig,} || true

    (
      cd jdownloader-browser
      # error: incompatible types: Charset cannot be converted to String
      patch -p1 < ${./src/jdownloader-browser-fix-charset-to-string.patch}
    )

    (
      cd jdownloader
      ant -buildfile build.xml | egrep -i --color "^|error|failed|fail"
    )

    # WONTFIX?
    # BUILD FAILED
    # jdownloader/build.xml:189: eclipse-workspace/JDClosed/src does not exist.
    # jdownloader/.project:33:                  <locationURI>WORKSPACE_LOC/JDClosed/src</locationURI>
    # jdownloader/build/newBuild/build.xml:4:   <property name="dep.jdc" value="../JDClosed" />

    ln -s ${./src/build-jar.xml} build-jar.xml
    ant -buildfile build-jar.xml
  '';
#src/build-jar.xml
  buildInputs = [
    jre
    #eclipses # cannot coerce a set to a string
    eclipses.eclipse-java
    #sources # cannot coerce a set to a string
    #appwork-utils
  ];

  nativeBuildInputs = [
    jdk ant
    #imagemagick copyDesktopItems
  ];

  # TODO better than dirname
  wrapper = writeShellScript "jdownloader-wrapper" ''
    PATH=${lib.makeBinPath buildInputs}
    exec java -jar $(dirname)/../lib/JDownloader.jar "$@"
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp *.jar $out/lib
    cp ${wrapper} $out/bin/jdownloader
  '';

  meta = with lib; {
    homepage = "https://jdownloader.org/";
    description = "Download manager";
    license = licenses.gpl3Plus;
    # TODO unfree. core is closed source (library JDClosed)
    #platforms = platforms.unix; actually all platforms ...
    #maintainers = with maintainers; [ remgodow ];
  };
}


/*
  desktopItems = [
    (makeDesktopItem {
      name = "JDownloader";
      exec = wrapper;
      icon = "jdownloader";
      comment = "Download manager";
      desktopName = "JDownloader";
      genericName = "JDownloader";
      categories = "Network;";
    })
  ];
*/


/*

    mkdir -p $out/bin $out/share/applications
    #cp ${src} $out/bin/JDownloader.jar
    # TODO
    echo installPhase TODO
    find . -name JDownloader.jar
    ls
    exit 1

    # create icons. JDownloader.png is 512x512
    for size in 16 32 48 64 72 96 128 192 512; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" \
        "${src}/jdownloader/artwork/icons/by TRazo/JDownloader/JDownloader.png" \
        $out/share/icons/hicolor/"$size"x"$size"/apps/jdownloader.png
    done
    */






#      ${eclipses.eclipse-cpp}/bin/eclipse -nosplash -data ./ -application org.eclipse.cdt.managedbuilder.core.headlessbuild -help

/*

      #ant -buildfile build/build.xml

      #cp build/build.xml build.xml
      #ant -buildfile build.xml

      # required for eclipse
      mkdir /tmp/home
      export HOME=/tmp/home


      # project name = AppWorkUtils

      # eclipsec.exe -noSplash -data "D:\Source\MyProject\workspace" -application org.eclipse.jdt.apt.core.aptBuild
      # cpp: org.eclipse.cdt.managedbuilder.core.headlessbuild # noop? (this is for C projects)
      # java: org.eclipse.jdt.apt.core.aptBuild # noop? (this should parse .classpath file)
      # ant: org.eclipse.ant.core.antRunner # starts to compile, but fails to parse .classpath file

      #echo
      echo run org.eclipse.jdt.apt.core.aptBuild ...
      eclipse -nosplash -data ./build/ -application org.eclipse.jdt.apt.core.aptBuild

      #echo
      #echo run org.eclipse.ant.core.antRunner ...
      #eclipse -nosplash -data ./ -application org.eclipse.ant.core.antRunner -buildfile build/build.xml

      echo org.eclipse.cdt.managedbuilder.core.headlessbuild -help 
      #eclipse -nosplash -data ./ -application org.eclipse.ant.core.antRunner -buildfile build/build.xml



noop
      echo run java ...
      java \
        -cp ${eclipses.eclipse-java}/eclipse/plugins/org.eclipse.equinox.launcher_1.6.100.v20201223-0822.jar \
        org.eclipse.core.launcher.Main \
        -nosplash \
        -application org.eclipse.jdt.apt.core.aptBuild \
        -data ./ \
        -buildfile build/build.xml \
        -build all \
        -verbose
*/
    /*

      # broken:
      false && eclipse \
        --launcher.suppressErrors \
        -nosplash \
        -application org.eclipse.jdt.apt.core.aptBuild \
        -data ./ \
        -build all \
      || {
        echo cat .metadata/.log
        cat .metadata/.log
        exit 1
      }
      */



