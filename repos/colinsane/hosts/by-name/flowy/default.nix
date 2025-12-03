{ lib, pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.pc = true;
  sane.roles.work = true;
  sane.services.wg-home.enable = true;
  sane.ovpn.addrV4 = "172.23.119.72";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:0332:aa96/128";

  # sane.guest.enable = true;

  sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.firefox.config.formFactor = "laptop";
  sane.programs.itgmania.enableFor.user.colin = true;
  sane.programs.sway.enableFor.user.colin = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.services.rsync-net.enable = true;

  # add an entry to boot into Windows, as if it had been launched directly from the BIOS.
  boot.loader.systemd-boot.rebootForBitlocker = true;
  boot.loader.systemd-boot.windows.primary.efiDeviceHandle = "HD0b";

  system.activationScripts.makeDefaultBootEntry = {
    text = let
      makeDefaultBootEntry = pkgs.writeShellApplication {
        name = "makeDefaultBootEntry";
        runtimeInputs = with pkgs; [
          efibootmgr
          gnugrep
        ];
        text = ''
          # configure the EFI firmware to boot into NixOS by default.
          # do this by querying the active boot entry, and just making that be the default.
          # this is needed on flowy because enabling secure boot / booting into Windows
          # resets the default boot order; manually reconfiguring that is tiresome.
          efi=$(efibootmgr)
          bootCurrent=$(echo "$efi" | grep '^BootCurrent: ')
          bootCurrent=''${bootCurrent/BootCurrent: /}
          bootOrder=$(echo "$efi" | grep '^BootOrder: ')
          bootOrder=''${bootOrder/BootOrder: /}
          if ! [[ "$bootOrder" =~ ^"$bootCurrent", ]]; then
            # booted entry was not the default,
            # so prepend it to the boot order:
            newBootOrder="$bootCurrent,$bootOrder"
            (set -x; efibootmgr -o "$newBootOrder")
          fi
        '';
      };
    in lib.getExe makeDefaultBootEntry;
  };
}
