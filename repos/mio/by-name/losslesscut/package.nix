{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  stdenv,
  ffmpeg,
  makeWrapper,
  jq,
  electron,
}:

buildNpmPackage rec {
  pname = "losslesscut";
  version = "3.68.1";

  src = stdenv.mkDerivation {
    name = "losslesscut-src";
    src = fetchFromGitHub {
      owner = "mifi";
      repo = "lossless-cut";
      rev = "v3.68.1";
      sha256 = "0yixkh94560r93qxpzdyyshabx6rj8279swx9lc7f3yhj229zv7m";
    };
    nativeBuildInputs = [ jq ];
    installPhase = ''
      cp -r $src $out
      chmod -R +w $out
      cp ${./package-lock.json} $out/package-lock.json
      # delete postinstall and replace yarn
      jq 'del(.scripts.postinstall) | .scripts.build = "npm run generate-icon && electron-vite build"' $out/package.json > $out/package2.json
      mv $out/package2.json $out/package.json
    '';
  };

  npmDepsHash = "sha256-Shq1xaO/XYsRshg9dh4R2ZsxPxv7XovI90ktDDTEqs8=";

  npmFlags = [ "--legacy-peer-deps" ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # No need for nativeBuildInputs since buildNpmPackage already handles npm install
  nativeBuildInputs = [
    makeWrapper
  ];

  npmBuildScript = "build";

  # installPhase handles copying the built app and wrapping
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/losslesscut
    cp -r out $out/lib/losslesscut/out
    cp package.json $out/lib/losslesscut/

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/losslesscut \
      --add-flags $out/lib/losslesscut \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}

    runHook postInstall
  '';

  meta = {
    description = "The swiss army knife of lossless video/audio editing";
    homepage = "https://mifi.no/losslesscut/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "losslesscut";
    platforms = lib.platforms.all;
  };
}
