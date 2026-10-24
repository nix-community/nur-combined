{ pkgs, inputs }:
let
  policy = import ../lib/ssh-policy.nix;
  client = inputs.self.nixosConfigurations.goliath.config;
  server = inputs.self.nixosConfigurations.daedalus.config;
  clientConfig = pkgs.writeText "ssh-client-config" client.environment.etc."ssh/ssh_config".text;
  proxyConfig = "${client.systemd.package}/lib/systemd/ssh_config.d/20-systemd-ssh-proxy.conf";
  serverConfig = server.environment.etc."ssh/sshd_config".source;
  expected = pkgs.writeText "ssh-policy.json" (builtins.toJSON policy);
in
pkgs.runCommand "ssh-policy-checks"
  {
    nativeBuildInputs = [
      pkgs.openssh
      pkgs.python3
    ];
  }
  ''
    cp ${clientConfig} ssh_config
    ${pkgs.lib.optionalString client.programs.ssh.systemd-ssh-proxy.enable ''
      # ssh -F requires included files to belong to its user or root, including in the build sandbox.
      cp ${proxyConfig} systemd-ssh-proxy.conf
      chmod u+w ssh_config
      substituteInPlace ssh_config \
        --replace-fail ${proxyConfig} "$PWD/systemd-ssh-proxy.conf"
    ''}
    python3 ${./ssh.py} ssh_config ${serverConfig} ${expected}
    touch "$out"
  ''
