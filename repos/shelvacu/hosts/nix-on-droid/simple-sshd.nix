{ lib, pkgs, ... }:
let
  port = 8022;
  key_path = "/data/data/com.termux.nix/files/home/ssh_host_ed25519_key";
  sshd_config = pkgs.writeText "sshd_config" ''
    HostKey ${key_path}
    Port ${toString port}
    AuthorizedKeysFile ${pkgs.vacu-authorized-keys}
    LogLevel DEBUG
    Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
  '';
  run_script = pkgs.writers.writeBashBin "termux-sshd" ''
    set -euo pipefail
    if ! [[ -e ${lib.escapeShellArg key_path} ]]; then
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ${lib.escapeShellArg key_path} -N ""
    fi

    echo "Will run on port ${toString port}"
    set -x
    exec ${pkgs.openssh}/bin/sshd -f ${sshd_config} -D
  '';
in
{
  vacu.packages = [ run_script ];
}
