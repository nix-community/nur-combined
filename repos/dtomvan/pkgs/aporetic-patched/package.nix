{
  stdenvNoCC,
  aporetic,
  nerd-font-patcher,
  parallel,
}:
stdenvNoCC.mkDerivation {
  pname = "aporetic-patched";
  inherit (aporetic) version meta;
  src = aporetic;

  nativeBuildInputs = [
    nerd-font-patcher
    parallel
  ];

  buildPhase = ''
    runHook preBuild

    ls -1 share/fonts/truetype/*.ttf \
      | parallel --will-cite --jobs=$NIX_BUILD_CORES nerd-font-patcher {} --complete --no-progressbars

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    for font in Aporetic*NerdFont*.ttf; do
      install -Dm444 "$font" -t $out/share/fonts/truetype
    done

    runHook postInstall
  '';
}
