{ pkgs, config, lib, specialArgs, ... }:
let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";
  port = 8022;
in
{
  environment.packages = with pkgs; [ 
    rsync
    vim
    openssh
    (pkgs.writeScriptBin "ssd" ''
      #!${pkgs.runtimeShell}

      echo "Starting sshd in non-daemonized way on port ${toString port}"
      ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '')
  ];

  system.stateVersion = "23.05";

	# Set your time zone.
	time.timeZone = "Europe/Vienna";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    trusted-users = root @wheel me
  '';


  build.activation.sshd = ''
    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""

      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort ${toString port}\n" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';
  
  home-manager.config = {
    home.file.".ssh/authorized_keys".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjgXf9S9hxjyph2EEFh1el0z4OUT9fMoFAaDanjiuKa me@main
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWsqiz0gEepvPONYxqhKKq4Vxfe1h+jo11k88QozUch me@bitwarden
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAioUu4ow6k+OMjjLdzogiQM4ZEM3TNekGNasaSDzQQE me@phone
    '';
    imports = [
      ../../users/common/home.nix
    ];
  };
}
