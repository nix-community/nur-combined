{ stdenv, syslinux }:

stdenv.mkDerivation rec {
  pname = "bootpart-uefi-x86_64";
  version = "1";

  buildInputs = [ syslinux ];

  dontUnpack = true;

  installPhase = ''
    # populate the EFI directory with syslinux, and configure it to read that extlinux.conf file managed by nixos
    mkdir -p "$out/EFI/syslinux"  "$out/EFI/BOOT"  "$out/syslinux"
    cp -R "${syslinux}/share/syslinux/efi64"/* "$out/EFI/syslinux"
    echo "DEFAULT trampoline" > "$out/EFI/syslinux/syslinux.cfg"
    echo "LABEL trampoline" >> "$out/EFI/syslinux/syslinux.cfg"
    echo "  SAY trampoline into generic extlinux.conf" >> "$out/EFI/syslinux/syslinux.cfg"
    echo "  CONFIG ../../syslinux/syslinux.cfg ../../syslinux" >> "$out/EFI/syslinux/syslinux.cfg"

    # we create this "trampoline" layer so that we can setup the UI directive
    # and enable a menu before loading the real, nixos-managed extlinux.conf
    cp "${syslinux}/share/syslinux/efi64/menu.c32" "$out/syslinux/menu.c32"
    echo "UI menu.c32" > "$out/syslinux/syslinux.cfg"
    echo "INCLUDE ../extlinux/extlinux.conf" >> "$out/syslinux/syslinux.cfg"
    
    # create the EFI/BOOT/BOOTX64.EFI default entry
    cp "$out/EFI/syslinux"/* "$out/EFI/BOOT"
    mv "$out/EFI/BOOT/syslinux.efi" "$out/EFI/BOOT/BOOTX64.EFI"
  '';


  meta = {
    description = "unmanaged files to place in /boot on a x86-64 extlinux system";
    platforms = [ "x86_64-linux" ];
  };
}

