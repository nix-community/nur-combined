{
  stdenvNoCC,
  lib,
  pkgs,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ide";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "adam-gaia";
    repo = "ide";
    rev = "6093a85bc7e5375ad9383ecccbff4a0ba87a7f17";
    hash = "sha256-zG6tTLuPNW40ckOAka0Bl5Fr4r1IDTszhdliWmOEGeU=";
  };

  buildInputs = with pkgs; [
    tmux
    neovim-remote
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    cp -r $src/ide.sh $out/bin/ide
    chmod +x $out/bin/ide

    runHook postInstall
  '';

  meta = with lib; {
    description = "TODO";
    homepage = "TODO";
    license = with licenses; [ mit ];
    maintainers = [ "Adam Gaia" ];
  };
}
