{
  stdenv,
  gradle,
  openjdk_headless,
  perl,
  git,
}: {
  src,
  sha256,
  ...
} @ args:
stdenv.mkDerivation ({
    nativeBuildInputs = [gradle openjdk_headless perl git];
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon --info -Dorg.gradle.java.home=${openjdk_headless} --write-verification-metadata sha256
    '';
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(aar\|jar\|pom\|module\)$' \
                | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/maven/$x/$3/$4/$5" #e' \
                | sh
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = sha256;
  }
  // args)
