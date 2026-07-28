{ lib, pkgs, ... }:

{
  imports = [
    ./flake-registry.nix
    ./simple-sshd.nix
  ];

  vacu.shell.color = "white";
  vacu.systemKind = "server";

  environment.etc."resolv.conf".text = lib.mkForce ''
    # nameserver 10.78.79.1
    nameserver 9.9.9.10
    nameserver 149.112.112.10

    options timeout:1 attempts:5
  '';

  user.shell =
    let
      asPkg = pkgs.writers.writeBashBin "bash-login" { } ''
        SHLVL= exec -a -bash ${lib.getExe pkgs.bashInteractive} --login -i "$@"
      '';
    in
    lib.getExe asPkg;

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "America/Los_Angeles";

  android-integration = {
    am.enable = true;
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-reload-settings.enable = true;
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    xdg-open.enable = true;
  };

  vacu.packages = lib.mkMerge [
    { jujutsu.enable = false; } # build is borked on aarch64-linux
    ''
      gnupg
      openssh
    ''
  ];
}
