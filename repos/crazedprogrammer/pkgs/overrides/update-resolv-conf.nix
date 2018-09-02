{ update-resolv-conf, lib, coreutils, openresolv, systemd, ... }:

# nix-collect-garbage -d kept removing the script, so I made this workaround.

let binPath = lib.makeBinPath [ coreutils openresolv systemd ];

in update-resolv-conf.overrideAttrs (old: {
  installPhase = ''
    install -Dm555 update-resolv-conf.sh $out/bin/update-resolv-conf
    wrapProgram $out/bin/update-resolv-conf --prefix PATH : ${binPath}
  '';
})
