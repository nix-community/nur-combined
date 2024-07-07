{ stdenv
, lib
, fetchFromGitHub
, makeDesktopItem
, jdk11
, makeWrapper
, maven
, mvn2nix
, localUsage ? false
}:

let
  mavenRepository =
   mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
in stdenv.mkDerivation rec {
  pname = "xtreme-download-manager";
  version = "7.2.11";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "subhra74";
    repo = "xdm";
    rev = "7.2.11";
    sha256 = "1p2mzaaig7fxk3gsk7r5shl1hijfz6bjlhmkqxgipywr1q1f67fb"; 
  };

  sourceRoot = "source/app";
  buildInputs = [ jdk11 maven makeWrapper ];
  buildPhase = ''
    echo "Building with maven repository ${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository}
    runHook postBuild
  '';

  postBuild = ''
    mv target/xdman.jar target/${name}.jar
  '';

  desktopItem = makeDesktopItem {
    name = "xdman";
    desktopName = "Xtreme Download Manager";
    type = "Application";
    exec = "xdman";
    terminal = false;
    icon = "xdman";
    comment = "Powerfull download accelarator and video downloader";
    categories = [ "Network" ];
  };

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a symbolic link for the lib directory
    ln -s ${mavenRepository} $out/lib

    # copy out the JAR
    # Maven already setup the classpath to use m2 repository layout
    # with the prefix of lib/
    cp target/${name}.jar $out/

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk11}/bin/java $out/bin/xdman \
          --add-flags "-jar $out/${name}.jar"
  
    install -Dm644 "${desktopItem}/share/applications/"* \
      -t $out/share/applications/
    install -Dm 644 src/main/resources/icons/xxhdpi/icon.png $out/share/icons/hicolor/128x128/apps/xdman.png
    install -Dm 644 src/main/resources/icons/xhdpi/icon.png $out/share/icons/hicolor/64x64/apps/xdman.png
    install -Dm 644 src/main/resources/icons/hdpi/icon.png $out/share/icons/hicolor/32x32/apps/xdman.png
  '';

  meta = with lib; {
    description = "Powerful download accelerator and video downloader ";
    homepage = "https://subhra74.github.io/xdm/";
    license = licenses.gpl2;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
    broken = ! localUsage;
  };
}
