
  /*
  github-downloader = stdenv.mkDerivation {
    pname = "github-downloader";
    version = "08049f6";
    src = fetchFromGitHub {
      owner = "Decad";
      repo = "github-downloader";
      rev = "08049f6183e559a9a97b1d144c070a36118cca97";
      sha256 = "073jkky5svrb7hmbx3ycgzpb37hdap7nd9i0id5b5yxlcnf7930r";
    };
    buildInputs = [ bash subversion coreutils cacert ]; # FIXME why is 'svn' not available when using github-downloader?
    nativeBuildInputs = [ makeWrapper ];
    # github-downloader.sh: line 26: svn: command not found
    # TODO add "set -e" to header of bash script = fail on errors (command not found)
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/bin
      cp github-downloader.sh $out/bin/github-downloader.sh
      # FIXME svn: E230001: Server SSL certificate verification failed: issuer is not trusted
      # -> is /etc/ssl/certs/ca-bundle.crt not working?
      substituteInPlace $out/bin/github-downloader.sh --replace "svn export" "stat /etc/ssl/certs/ca-bundle.crt; svn --trust-server-cert-failures=unknown-ca export"
      wrapProgram $out/bin/github-downloader.sh \
        --prefix PATH : ${lib.makeBinPath [ bash subversion coreutils ]}
    '';
  };
  */

  /* WONTFIX? this is crazy complicated.
  fetchFromGitHubPath = { path, repo, owner, rev, sha256 }:
    # path can be path to directory or file (src/ or src/foo.txt)
    let
      shortRev = builtins.substring 0 7 rev;
    in
    stdenv.mkDerivation {
      name = "github--${owner}--${repo}--${shortRev}--source-path";
      #src = fetchFromGitHub cleanAttrs;
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = sha256;
      builder = writeShellScript "builder.sh" ''
        # WONTFIX cannot fetch by rev :( only trunk/branch/tag
        #${github-downloader}/bin/github-downloader.sh "https://github.com/${owner}/${repo}/tree/${rev}/${path}"
        ${github-downloader}/bin/github-downloader.sh "https://github.com/${owner}/${repo}/tree/trunk/${path}"
      '';
      buildInputs = [ github-downloader ];
    };
  */

  fetchSubversion = { name, url, sha256 }:
    /*
    let
      shortRev = builtins.substring 0 7 rev;
    in
    */
    # TODO pin to commit hash
    stdenv.mkDerivation {
      inherit name;
      #name = "github--${owner}--${repo}--${shortRev}--source-path";
      #src = fetchFromGitHub cleanAttrs;
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = sha256;
      builder = writeShellScript "builder.sh" ''
        ${subversion}/bin/svn co --quiet ${url}
        ${coreutils}/bin/mv * $out
      '';
      buildInputs = [ subversion coreutils ];
    };



  /*
  50 MByte jre + 5 MByte jdownloader ... -> use 5 MByte https://archive.org/download/jdownloader_202109/JDownloader.jar
  src = fetchFromMegaNz {
    # https://jdownloader.org/download/index
    name = "jdownloader-linux64-setup-sh";
    url = "https://mega.nz/file/LJ9FyK7b#t88t6YBo2Wm_ABkSO7GikxujDF5Hddng9bgDb8fwoJQ"; # linux 64 bit
    # filename = JD2Setup_x64.sh
    sha256 = "ddd1a997afaf60c981fbfb1a1f3a600ff7bad7fccece9f2508fb695b8c2f153d";
    #sha256 = jdownloader-sha256;
  };
  dontUnpack = true;
  */




  fetchFromMegaNz = { name, url, sha256, isDir ? false }:
    # isDir: mega.nz allows to download folders
    # with isDir == false, the remote filename is ignored
    # for single files, isDir == true will produce a different sha256 than isDir == false
    stdenv.mkDerivation {
      inherit name;
      outputHashMode = if isDir then "recursive" else "flat";
      outputHashAlgo = "sha256";
      outputHash = sha256;
      builder = writeShellScript "builder.sh" ''
        PATH=${lib.makeBinPath [ megacmd coreutils ]}

        # workaround for https://github.com/meganz/MEGAcmd/issues/580
        export HOME=/tmp/home
        mkdir -p $HOME

        mkdir tmpdir
        cd tmpdir
        mega-get ${url}

        ${
          if isDir
          then ''
            mkdir $out
            mv * $out
          ''
          else ''
            if [ $(ls -A | wc -l) -ne 1 ]; then
              echo "error: isDir is false, but download produced multiple files:"
              ls -A
              exit 1
            fi
            mkdir $out
            cd ..
            mv tmpdir $out
          ''
        }
      '';
      buildInputs = [ megacmd coreutils ];
    };
    
# TODO JDBrowser
# TODO co-depend: JDownloader MyJDownloaderClient

  appwork-utils = stdenv.mkDerivation rec {
    pname = "jdownloader";
    version = "2021-10-03";
    /*
    src = fetchFromGitHub {
      repo = pname;
      owner = "milahu";
      rev = "23f8ea5abe37f2760c6193cb2f50e749e12f434f";
      sha256 = "1bqv4xrflxsdy381zzc15k3s12b4193vf4pxa6x1p3m2v0ydaaaa"; # todo
    };
    */
    src = ./src;


    # https://nixos.org/manual/nixpkgs/stable/#sec-language-java
    #  find . -name build.xml
    # [javac] error: Source option 6 is no longer supported. Use 7 or later.
    # source: The version that your source code requires to compile.
    # target: The oldest JRE version you want to support.
    # https://stackoverflow.com/questions/15492948/javac-source-and-target-options
    # 'javac -version' says 16 ... what? why not 1.6 or 1.7?
    # TODO     [javac] /build/appwork-utils-svn-source/build/build.xml:21: warning: 'includeantruntime' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds
    # https://gnu-mcu-eclipse.github.io/advanced/headless-builds/
    buildPhase = ''
      echo "patching java source and target version from 1.6 to 1.7"
      substituteInPlace build/build.xml --replace 'source="1.6" target="1.6"' 'source="1.7" target="1.7"'

      echo adding libs from .classpath file
      # TODO automatically parse the .classpath file?
      substituteInPlace build/build.xml \
        --replace \
          '<fileset dir="libs" includes="*.jar" />' \
          '<fileset dir="libs" includes="*.jar" /><fileset dir="dev_libs" includes="*.jar" />'

      echo "removing target 'sign'"
      xmlstarlet ed --inplace --omit-decl build/build.xml # format xml. xmlstarlet fails to preserve all formatting (diff noise)
      xmlstarlet ed --pf --omit-decl \
        --delete "/project/target[@name='sign']" \
        --update "/project/target[@name='standardBuild']/@depends" --value compile,jar \
        build/build.xml > build/build.xml.patched
      diff -u --color build/build.xml build/build.xml.patched || true # diff returns nonzero when files are different
      cp build/build.xml.patched build/build.xml

      echo running ant ...
      ant -buildfile build/build.xml
    '';

    installPhase = ''
      find . -name '*.jar'
      exit 1
      # JAR files that are intended to be used by other packages
      # should be installed in $out/share/java.
    '';

    /*
    FIXME dont sign
    sign:
      [signjar] Signing JAR: /build/AppWorkUtils/dist/appworkutils.jar to /build/AppWorkUtils/dist/appworkutils.jar as ${appwork_java_cert_alias}
      [signjar] jarsigner error: java.lang.RuntimeException: keystore load: /build/AppWorkUtils/${appwork_java_cert} (No such file or directory)
    */

    nativeBuildInputs = [
      jdk ant
      #eclipses.eclipse-java jre
      #eclipses.eclipse-cpp
      xmlstarlet diffutils
    ];
