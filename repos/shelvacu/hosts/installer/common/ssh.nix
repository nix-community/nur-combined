{ lib, pkgs, ... }: {
  services.openssh.generateHostKeys = false;
  services.openssh.hostKeys = lib.mkForce [
    {
      path = "/run/installer-ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  services.openssh.settings.HostCertificate = "/run/installer-ssh/ssh_host_ed25519_key-cert.pub";
  systemd.services.sshd = {
    requires = [ "installer-ssh.service" ];
    after = [ "installer-ssh.service" ];
  };
  systemd.services.installer-ssh = {
    description = "Generate and certify the installer SSH host key";
    before = [ "sshd.service" ];
    path = [
      pkgs.openssh
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "installer-ssh";
      RuntimeDirectoryMode = "0700";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
      UMask = "0077";
    };
    script = ''
      key=/run/installer-ssh/ssh_host_ed25519_key
      ca=/run/installer-ssh-ca
      ssh-keygen -q -t ed25519 -N "" -f "$key"
      ssh-keygen -s "$ca/key" -I "installer-$(cat /proc/sys/kernel/random/uuid)" \
        -h -n "$(cat "$ca/principals")" -V "$(cat "$ca/validity")" "$key.pub"
      echo 'Installer SSH host public key:'
      cat "$key.pub"
      ssh-keygen -l -E sha256 -f "$key.pub"
    '';
  };
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.storePaths = [ pkgs.coreutils ];
  boot.initrd.systemd.services.installer-ssh-ca = {
    description = "Load the installer SSH signing key";
    wantedBy = [ "initrd.target" ];
    before = [ "initrd-switch-root.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/install -d -m 0700 /run/installer-ssh-ca
      ${pkgs.coreutils}/bin/install -m 0600 /installer-ssh-ca/* /run/installer-ssh-ca/
    '';
  };
}
