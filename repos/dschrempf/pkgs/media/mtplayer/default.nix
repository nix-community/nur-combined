{
  # Build.
  fetchzip,
  lib,
  stdenv,
  writeShellScriptBin,
  # Dependencies.
  ffmpeg,
  jre,
  vlc,
}:

let
  mtplayer = stdenv.mkDerivation (finalAttrs: {
    pname = "mtplayer";
    version = "version-17";

    # # Building from source does not really work because Gradle wants to download dependencies...
    # src = fetchFromGitHub {
    #   owner = "xaverW";
    #   repo = "MTPlayer";
    #   rev = finalAttrs.version;
    #   hash = "sha256-Mqj65XLFIm2WJ4ZDpWAiXa73lcKyDIclc3xkmWLVrEI=";
    # };
    #
    # preConfigure = ''
    #   gradle init --overwrite --project-name MTPlayer --type basic --dsl groovy --use-defaults
    #   cp ./build-infos/build.gradle ./build.gradle
    #   cp ./build-infos/settings.gradle ./settings.gradle
    #   cp ./build-infos/gitignore ./.gitignore
    # '';

    src = fetchzip {
      url = "https://github.com/xaverW/MTPlayer/releases/download/version-17/MTPlayer-17__Linux.mit.Java__2024.06.01.zip";
      hash = "sha256-rxn/33VdJ9In01+G9trVWnFTPHpCAaRMHGJ137Xx/as=";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp MTPlayer.jar $out/bin
    '';

    meta = with lib; {
      description = "Access media centers of different TV stations (ARD, ZDF, Arte, etc.)";
      homepage = "https://www.p2tools.de/mtplayer/";
      license = licenses.gpl3;
      maintainers = with maintainers; [ dschrempf ];
    };

    # nativeBuildInputs = [ gradle ];
    buildInputs = [
      jre
      vlc
      ffmpeg
    ];
    # propagatedBuildInputs = [ ];
  });
in
writeShellScriptBin "mtplayer" ''
  ${jre}/bin/java -jar ${mtplayer}/bin/MTPlayer.jar
''
