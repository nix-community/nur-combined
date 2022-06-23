{ lib, makeWrapper, openssh, rsync, sshpass, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "drone-rsync";
  version = "0.1.0";

  src = ./drone-rsync;

  buildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod a+x $out/bin/${pname}
  '';

  wrapperPath = lib.makeBinPath [
    openssh
    rsync
    sshpass
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "Helper script to run rsync in a CI pipeline";
    homepage = "https://gitea.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
