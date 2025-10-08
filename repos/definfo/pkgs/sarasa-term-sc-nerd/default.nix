# Derived from <nixpkgs>/pkgs/by-name/sh/shanggu-fonts/package.nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
  variance ? "hinted",
}:

assert lib.asserts.assertOneOf "Font variance" variance [
  "hinted"
  "unhinted"
];

let
  version = "2.3.1";

  source = {
    hinted = fetchurl {
      url = "https://github.com/laishulu/Sarasa-Term-SC-Nerd/releases/download/v${version}/SarasaTermSCNerd.ttc.7z";
      hash = "sha256-uigBn39Lfvqzn1Tmy8mPDRAs/WQj7EnfI0K0xYK18wA=";
    };
    unhinted = fetchurl {
      url = "https://github.com/laishulu/Sarasa-Term-SC-Nerd/releases/download/v${version}/SarasaTermSCNerd-Unhinted.ttc.7z";
      hash = "sha256-FFWjb0E3YB2n4wv2twrQmKgdadlcmzq6JyL6uaUUo1k=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "sarasa-term-sc-nerd";
  inherit version;

  src = source.${variance};

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    runHook preUnpack

    7z x $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -Dm444 SarasaTermSCNerd.ttc -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/laishulu/Sarasa-Term-SC-Nerd";
    description = "Nerd font based on Sarasa Term SC";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ definfo ];
  };
}
