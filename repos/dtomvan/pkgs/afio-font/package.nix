{
  lib,
  stdenv,
  fetchFromGitHub,
  iosevka,
  ttfautohint-nox,
  fontforge,
  python3,
  nodejs,
  npmHooks,
  fetchNpmDeps,
}:
let
  version = "0.0.13";
  afioHash = "sha256-jBdYFcSu0kbcaVG8cMbtKw4qP+6snQirOEu7RYBBbc4=";
  isRc = true;
  versionTag = "v${version}${if isRc then "-rc" else ""}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "afio-font";
  inherit version;

  src = fetchFromGitHub {
    owner = "awnion";
    repo = "custom-iosevka-nerd-font";
    rev = "${versionTag}";
    hash = afioHash;
  };

  nativeBuildInputs = [
    (python3.withPackages (p: [ p.fontforge ]))
    fontforge
    ttfautohint-nox
    nodejs
  ];

  npmDeps = fetchNpmDeps {
    src = "${iosevka.src}";
    hash = iosevka.npmDepsHash;
  };

  configurePhase = ''
    runHook preConfigure

    export BUILD_DIR=build
    export OUTPUT_DIR=out
    export FONT_NAME=afio

    mkdir $BUILD_DIR $OUTPUT_DIR

    cp -r ${iosevka.src} $BUILD_DIR/iosevka
    chmod -R +w $BUILD_DIR/iosevka
    cp private-build-plans.toml $BUILD_DIR/iosevka

    source ${npmHooks.npmConfigHook}/nix-support/setup-hook
    npmRoot=$BUILD_DIR/iosevka npmConfigHook

    mv nerd/font-patcher .
    mv nerd/glyphs src

    chmod +x font-patcher
    patchShebangs .

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd $BUILD_DIR/iosevka
      npm run build -- ttf::afio
    popd

    python3 src/docker_run.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 $OUTPUT_DIR/*.ttf -t $out/share/fonts/truetype/afio

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Custom slimmed down Iosevka font with nerd-font icons";
    homepage = "https://github.com/awnion/custom-iosevka-nerd-font";
    # License unspecified
    # https://github.com/awnion/custom-iosevka-nerd-font/issues/3
    license = "unfree";
    platform = lib.platforms.all;
    maintainers = with lib.maintainers; [ dtomvan ];
  };
})
