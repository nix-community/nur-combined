{ fzf, lib, makeWrapper, nix-index, shellcheck, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "comma";
  version = "0.1.0";

  src = ./. + "/comma";

  phases = [ "buildPhase" "installPhase" "fixupPhase" ];

  buildInputs = [
    makeWrapper
    shellcheck
  ];

  buildPhase = ''
    shellcheck $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${meta.mainProgram}
    chmod a+x $out/bin/${meta.mainProgram}
  '';

  wrapperPath = lib.makeBinPath [
    fzf
    nix-index
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${meta.mainProgram}
    wrapProgram $out/bin/${meta.mainProgram} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    mainProgram = ",";
    description = "A simple script inspired by Shopify's comma, for modern Nix";
    homepage = "https://gitea.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
  };
}
