{ stdenv
, lib
, sway-unwrapped
, coreutils
, sway
, grim
, slurp
, wl-clipboard
, jq
, libnotify
, installShellFiles
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "grimshot";
  inherit (sway-unwrapped) src version;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ installShellFiles makeWrapper ];
  installPhase = ''
    runHook preInstall
    installManPage ./contrib/grimshot.1
    install -D -m755 ./contrib/grimshot $out/bin/grimshot
    wrapProgram $out/bin/grimshot \
      --set PATH "${lib.makeBinPath [ coreutils jq sway grim slurp wl-clipboard libnotify ]}"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Helper for screenshots within sway";
    inherit (sway-unwrapped.meta) homepage license;
  };
}
