{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{

  config = {
    home.packages = [
      # pkgs.nur.repos.avycado13.anylinuxfs-gui

      # Basic Utilities
      pkgs.onefetch
      pkgs.fastfetch
      pkgs.caligula
      pkgs.magic-wormhole
      pkgs.curl
      pkgs.wget
      pkgs.htop
      pkgs.btop
      pkgs.tree
      pkgs.cowsay
      pkgs.file
      pkgs.jnv
      pkgs.serie
      pkgs.which
      pkgs.gnused
      pkgs.gnutar
      pkgs.gawk
      pkgs.coreutils
      # pkgs.pkgconf
      pkgs.restic
      pkgs.gum
      pkgs.jq
      pkgs.ts
      pkgs.hyperfine
      pkgs.duf
      pkgs.wireguard-tools
      pkgs.exiftool
      pkgs.chafa
      pkgs.lesspipe
      pkgs.hledger
      (
        (pkgs.buku.override {
          withServer = true;
        }).overrideAttrs
          (old: {
            doCheck = false;
            doInstallCheck = false;
            preCheck = (old.preCheck or "") + ''
              rm tests/test_{server,views}.py
            '';
          })
      )
      pkgs.dos2unix
      pkgs.bunbun
      pkgs.glow
      pkgs.just
      pkgs.ddgr
      # pkgs.mplayer
      # pkgs.beets

      pkgs.pipes
      pkgs.cbonsai
      pkgs.tarts
      pkgs.macchina
      pkgs.cloudflared
      pkgs.hexyl
      pkgs.sd
      pkgs.captive-browser
      pkgs.grc
      pkgs.scooter
      pkgs.dua
      pkgs.procs
      inputs.niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3

      pkgs.pigz

      # Scripts
      (pkgs.writeShellScriptBin "gcomp" ''
              fzf \
            --disabled \
        --prompt "Google❯ " \
            --bind 'change:reload:Q=$(echo {q} | sed "s/ /+/g"); curl -s "https://suggestqueries.google.com/complete/search?client=firefox&q=$Q" 2>/dev/null | python3 -c "import sys,json; [print(s) for s in json.load(sys.stdin)[1]]" 2>/dev/null || true' \
            --height=30% \
            --border=rounded \
            --color=prompt:cyan \
            --print-query \
            < /dev/null
      '')
    ];
  };
}
