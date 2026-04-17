{
  flake.modules.nixos.ssh =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      programs.ssh = {
        # startAgent = true;
        enableAskPassword = true;
        askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
      };
      systemd.tmpfiles.rules = [
        "L+ /home/${config.identity.user}/.ssh/config - - - - ${pkgs.writeText "ssh-config" ''
          ${lib.concatLines (
            let
              hosts = config.data.node;
            in
            lib.mapAttrsToList (n: v: ''
              Host ${n}
                  HostName ${
                    if
                      lib.elem config.networking.hostName [
                        "kaambl"
                        "eihort"
                        "hastur"
                      ]
                    then
                      config.fn.getAddrFromCIDR v.unique_addr
                    else if v ? addrs then
                      config.fn.getAddrFromCIDR v.unique_addr
                    else
                      (lib.elemAt v.identifiers 0).name
                  }
                  User ${v.user}
                  AddKeysToAgent yes
                  ForwardAgent yes
            '') hosts
          )}
          Host gitee.com
              HostName gitee.com
              User riro

          Host github.com
              HostName ssh.github.com
              User git
              Port 443

          Host git.dn42.dev
              HostName git.dn42.dev
              User git
              Port 22

          Host *
              # ControlMaster auto
              # ControlPath ~/.ssh/%r@%h:%p.socket
              # ControlPersist 10m
              Port 22
              IdentityFile /persist/keys/sept.pub
              IdentitiesOnly yes
              HashKnownHosts yes
        ''}"
        "L+ /root/.ssh/config - - - - /home/${config.identity.user}/.ssh/config"
      ];
    };
}
