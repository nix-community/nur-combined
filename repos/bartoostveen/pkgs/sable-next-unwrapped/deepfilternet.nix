{
  stdenv,
  lib,
  sable-next-unwrapped,
  nodejs_26,
  cacert,
  nix-update-script,
}:

let
  nodejs = nodejs_26;
in
stdenv.mkDerivation {
  pname = "sable-next-deepfilternet-assets";
  inherit (sable-next-unwrapped)
    version
    src
    patches
    ;

  __structuredAttrs = true;
  strictDeps = true;

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-Qq209UVT88O064TorOgv3a6Id1EAS+owVFRpG85fLH0=";

  nativeBuildInputs = [
    nodejs
    cacert
  ];

  installPhase = ''
    node scripts/build/fetch-deepfilternet.mjs
    mv static/deepfilternet3 $out
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Noise suppression using deep filtering for Sable";
    homepage = "https://github.com/Rikorose/DeepFilterNet";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ bartoostveen ];
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
    ];
  };
}
