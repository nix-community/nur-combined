{
  stdenv,
  fetchurl,
  p7zip,
  nix-update-script,
  lndir,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plangothic";
  version = "2.9.5787";
  src = fetchurl {
    url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project/releases/download/V${finalAttrs.version}/Plangothic-Super-V${finalAttrs.version}.7z";
    sha256 = "sha256-kab4d8ChPFzlsJlhwkpA4FmvRiGNPH0Cq6+Onsc/oy4=";
  };
  nativeBuildInputs = [
    p7zip
    lndir
  ];
  outputs = [
    "out"
    "otc"
    "otf"
    "ttc"
    "ttf"
    "woff2"
  ];
  installPhase = ''
    runHook preInstall
    install -D --mode=444 otf/*.ttc    --target-directory="$otc/share/fonts/opentype/"
    install -D --mode=444 otf/*.otf    --target-directory="$otf/share/fonts/opentype/"
    install -D --mode=444 static/*.ttc --target-directory="$ttc/share/fonts/truetype/"
    install -D --mode=444 static/*.ttf --target-directory="$ttf/share/fonts/truetype/"
    install -D --mode=444 web/*.woff2  --target-directory="$woff2/share/fonts/woff2/"
    mkdir --parents "$out/share/fonts"
    for format_dir in "$otc" "$otf" "$ttc" "$ttf" "$woff2"; do
      lndir "$format_dir" "$out"
    done
    runHook postInstall
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script {
      attrPath = finalAttrs.pname;
      extraArgs = [
        "--version-regex"
        "V(.*)"
      ];
    };
  };

  meta = {
    homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project";
    description = "Font based on Source Han Sans, following Mainland China glyph standards, with glyph coverage for the CJK Unified Ideographs Extension blocks.";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ yinfeng ];
  };
})
