{ lib, writeText, stdenv, jdk, maven, makeWrapper, nix-gitignore
, bootstrap ? false, buildMavenRepositoryFromLockFile }:
let
  repository = (if bootstrap then
    stdenv.mkDerivation {
      name = "bootstrap-repository";
      buildInputs = [ jdk maven ];
      src = nix-gitignore.gitignoreSource [] ./.;
      buildPhase = ''
        mkdir $out

        while mvn package -Dmaven.repo.local=$out -Dmaven.wagon.rto=5000; [ $? = 1 ]; do
          echo "timeout, restart maven to continue downloading"
        done
      '';
      # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
      installPhase = ''
        find $out -type f \
          -name \*.lastUpdated -or \
          -name resolver-status.properties -or \
          -name _remote.repositories \
          -delete
      '';

      # don't do any fixup
      dontFixup = true;

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "09jx8kpj0wsi7rshczfpkp77dpfhybdrfkazf1i3s48s3kckz32r";
    }
  else
    buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; });
in stdenv.mkDerivation rec {
  pname = "mvn2nix";
  version = "0.1";
  name = "${pname}-${version}";
  src = nix-gitignore.gitignoreSource [] ./.;
  buildInputs = [ jdk maven makeWrapper ];
  buildPhase = ''
    echo "Using repository ${repository}"
    # 'maven.repo.local' must be writable so copy it out of nix store
    mvn package --offline -Dmaven.repo.local=${repository}
  '';

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a symbolic link for the lib directory
    ln -s ${repository} $out/lib

    # copy out the JAR
    # Maven already setup the classpath to use m2 repository layout
    # with the prefix of lib/
    cp target/${name}.jar $out/

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk}/bin/java $out/bin/${pname} \
          --add-flags "-jar $out/${name}.jar" \
          --set M2_HOME ${maven} \
          --set JAVA_HOME ${jdk}
  '';

  meta = with lib; {
    description =
      "Easily package your Java applications for the Nix package manager.";
    homepage = "https://github.com/fzakaria/mvn2nix";
    license = licenses.mit;
    maintainers = [ "farid.m.zakaria@gmail.com" ];
    platforms = platforms.all;
  };
}
