{
  lib,
  stdenvNoCC,
  fetchpatch,
  lzma,
  source,
  undmg,
}:
let
  undmg' = undmg.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        # https://github.com/matthewbauer/undmg/pull/11
        name = "support-lzma patch";
        url = "https://github.com/matthewbauer/undmg/commit/bc134e3f8d03b43a17e986d8164d583b50535ace.patch";
        hash = "sha256-WsW8QU4dt43GHe2E/HzbHb6VSa7JGupn//f4PeIonxQ=";
      })
    ];
    buildInputs = oldAttrs.buildInputs ++ [ lzma ];
  });
in

stdenvNoCC.mkDerivation {
  pname = "vivaldi";
  inherit (source) version src;

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg' ];

  sourceRoot = "Vivaldi.app";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Vivaldi.app
    cp -R . $out/Applications/Vivaldi.app

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Browser for our Friends powerful and personal";
    homepage = "https://vivaldi.com";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ natsukium ];
  };
}
