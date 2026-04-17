{
  flake.modules.nixos.base-pkgs =
    {
      pkgs,
      lib,
      ...
    }:
    let
      p = with pkgs; {

        net = [
          # anti-censor
          [
            sing-box
            tor
            arti
            oniux
          ]

          [
            rustscan
            stun
            bandwhich
            iperf3
            dnsutils
            tcpdump
            netcat
            wget
            socat
            miniserve
            mtr
            q
            nali
            nethogs
            dig
            wireguard-tools
            # curlFull
            (curl.override {
              ldapSupport = true;
              gsaslSupport = true;
              rtmpSupport = true;
              pslSupport = true;
              websocketSupport = true;
              # echSupport = true;
            })
            xh
            # ngrep
            gping
            tcping-go
            # httping
            iftop
            # cilium-cli
          ]
        ];
        cmd = [
          eza
          fzf
          mcrcon

          smartmontools
          # attic
          ntfy-sh
          helix
          srm
          # onagre

          # common
          [
            killall
            jq
            fx
            bottom
            lsd
            htop
            fd
            choose
            duf
            tokei
            procs
            lsof
            tree
            bat
          ]
          [
            ripgrep
            b3sum
            coreutils
            traceroute
            rsync
          ]
        ];

      };
    in
    {
      environment.systemPackages = lib.flatten (lib.attrValues p);
    };
}
