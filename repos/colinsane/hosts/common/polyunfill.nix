# strictly *decrease* the scope of the default nixos installation/config

{ config, lib, pkgs, ... }:
let
  suidlessPam = pkgs.pam.overrideAttrs (upstream: {
    # nixpkgs' pam hardcodes unix_chkpwd path to the /run/wrappers one,
    # but i don't want the wrapper, so undo that.
    # ideally i would patch this via an overlay, but pam is in the bootstrap so that forces a full rebuild.
    # see: <repo:nixos/nixpkgs:pkgs/by-name/li/linux-pam/package.nix>
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace modules/module-meson.build --replace-fail \
        "/run/wrappers/bin/unix_chkpwd" "$out/bin/unix_chkpwd"
    '';
  });
  # `mkDefault` is `mkOverride 1000`.
  # `mkOverrideDefault` will override `mkDefault` values, but not ordinary values.
  mkOverrideDefault = lib.mkOverride 900;
in
{
  # remove a few items from /run/wrappers we don't need.
  options.security.wrappers = lib.mkOption {
    apply = lib.filterAttrs (name: _: !(builtins.elem name [
      # from <repo:nixos/nixpkgs:nixos/modules/security/polkit.nix>
      "pkexec"
      "polkit-agent-helper-1"  #< used by systemd; without this you'll have to `sudo systemctl daemon-reload` instead of unauth'd `systemctl daemon-reload`
      # from <repo:nixos/nixpkgs:nixos/modules/services/system/dbus.nix>
      "dbus-daemon-launch-helper"
      # from <repo:nixos/nixpkgs:nixos/modules/security/wrappers/default.nix>
      "fusermount"  #< only needed if you want to mount entries declared in /etc/fstab or mtab as unprivileged user
      "fusermount3"
      "mount"  #< only needed if you want to mount entries declared in /etc/fstab or mtab as unprivileged user
      "umount"
      # from <repo:nixos/nixpkgs:nixos/modules/programs/shadow.nix>
      "newgidmap"
      "newgrp"
      "newuidmap"
      "sg"
      "su"
      # from: <repo:nixos/nixpkgs:nixos/modules/security/pam.nix>
      # requires associated `pam` patch to not hardcode unix_chkpwd path
      "unix_chkpwd"
    ]));
  };
  options.security.pam.services = lib.mkOption {
    apply = lib.filterAttrs (name: _: !(builtins.elem name [
      # from <repo:nixos/nixpkgs:nixos/modules/security/pam.nix>
      "i3lock"
      "i3lock-color"
      "vlock"
      "xlock"
      "xscreensaver"
      "runuser"
      "runuser-l"
      # from ??
      "chfn"
      "chpasswd"
      "chsh"
      "groupadd"
      "groupdel"
      "groupmems"
      "groupmod"
      "useradd"
      "userdel"
      "usermod"
      # from <repo:nixos/nixpkgs:nixos/modules/system/boot/systemd/user.nix>
      # "systemd-user"  #< N.B.: this causes the `systemd --user` service manager to fail 224/PAM!
    ]));
  };

  options.environment.systemPackages = lib.mkOption {
    # see: <repo:nixos/nixpkgs:nixos/modules/config/system-path.nix>
    # it's 31 "requiredPackages", with no explanation of why they're "required"...
    # most of these can be safely removed without breaking the *boot*,
    # but some core system services DO implicitly depend on them.
    # TODO: see which more of these i can remove (or shadow/sandbox)
    apply = let
      requiredPackages = builtins.map (pkg: lib.setPrio ((pkg.meta.priority or 5) + 3) pkg) [
        # pkgs.acl
        # pkgs.attr
        # pkgs.bashInteractive
        # pkgs.bzip2
        # pkgs.coreutils-full
        # pkgs.cpio
        # pkgs.curl
        # pkgs.diffutils
        # pkgs.findutils
        # pkgs.gawk
        # pkgs.stdenv.cc.libc
        # pkgs.getent
        # pkgs.getconf
        # pkgs.gnugrep
        # pkgs.gnupatch
        # pkgs.gnused
        # pkgs.gnutar
        # pkgs.gzip
        # pkgs.xz
        pkgs.less
        # pkgs.libcap  #< implicitly required by NetworkManager/wpa_supplicant!
        # pkgs.ncurses
        pkgs.netcat
        # config.programs.ssh.package
        # pkgs.mkpasswd
        pkgs.procps
        # pkgs.su
        # pkgs.time
        # pkgs.util-linux
        # pkgs.which
        # pkgs.zstd
      ];
      conveniencePackages = [
        config.boot.kernelPackages.cpupower  # <repo:nixos/nixpkgs:nixos/modules/tasks/cpu-freq.nix> places it on PATH for convenience if powerManagement.cpuFreqGovernor is set
        pkgs.kbd  # <repo:nixos/nixpkgs:nixos/modules/config/console.nix>  places it on PATH as part of console/virtual TTYs, but probably not needed unless you want to set console fonts
        pkgs.nixos-firewall-tool  # <repo:nixos/nixpkgs:nixos/modules/services/networking/firewall.nix>  for end-user management of the firewall? cool but doesn't cross-compile
      ];
    in lib.filter (p: ! builtins.elem p (requiredPackages ++ conveniencePackages));
  };

  options.system.fsPackages = lib.mkOption {
    # <repo:nixos/nixpkgs:nixos/modules/tasks/filesystems/vfat.nix>  adds `mtools` and `dosfstools`
    # dosfstools actually makes its way into the initrd (`fsck.vfat`).
    # mtools is like "MS-DOS for Linux", ancient functionality i'll never use.
    apply = lib.filter (p: p != pkgs.mtools);
  };

  config = {
    # disable non-required packages like nano, perl, rsync, strace
    environment.defaultPackages = [];

    # remove all the non-existent default directories from XDG_DATA_DIRS, XDG_CONFIG_DIRS to simplify debugging.
    # this is defaulted in <repo:nixos/nixpkgs:nixos/modules/programs/environment.nix>,
    # without being gated by any higher config.
    environment.profiles = lib.mkForce [
      "/etc/profiles/per-user/$USER"
      "/run/current-system/sw"
    ];

    # NIXPKGS_CONFIG defaults to "/etc/nix/nixpkgs-config.nix" in <nixos/modules/programs/environment.nix>.
    # that's never existed on my system and everything does fine without it set empty (no nixpkgs API to forcibly *unset* it).
    environment.variables.NIXPKGS_CONFIG = lib.mkForce "";
    # XDG_CONFIG_DIRS defaults to "/etc/xdg", which doesn't exist.
    # in practice, pam appends the values i want to XDG_CONFIG_DIRS, though this approach causes an extra leading `:`
    # XXX(2025-06-06): some nixpkgs' systemd services actually depend on the default XDG_CONFIG_DIRS=/etc/xdg!
    # specifically: `services.bitmagnet`
    # environment.sessionVariables.XDG_CONFIG_DIRS = lib.mkForce [];
    # XCURSOR_PATH: defaults to `[ "$HOME/.icons" "$HOME/.local/share/icons" ]`, neither of which i use, just adding noise.
    # see: <repo:nixos/nixpkgs:nixos/modules/config/xdg/icons.nix>
    environment.sessionVariables.XCURSOR_PATH = lib.mkForce [];

    environment.shellAliases = {
      # unset default aliases; see <repo:nixos/nixpkgs:nixos/modules/config/shells-environment.nix>
      ls = mkOverrideDefault null;
      ll = mkOverrideDefault null;
      l = mkOverrideDefault null;
    };

    # disable nixos' portal module, otherwise /share/applications gets linked into the system and complicates things (sandboxing).
    # instead, i manage portals myself via the sane.programs API (e.g. sane.programs.xdg-desktop-portal).
    xdg.portal.enable = false;
    xdg.menus.enable = false;  #< links /share/applications, and a bunch of other empty (i.e. unused) dirs

    # xdg.autostart.enable defaults to true, and links /etc/xdg/autostart into the environment, populated with .desktop files.
    # see: <repo:nixos/nixpkgs:nixos/modules/config/xdg/autostart.nix>
    # .desktop files are a questionable way to autostart things: i generally prefer a service manager for that.
    xdg.autostart.enable = false;

    # nix.channel.enable: populates `/nix/var/nix/profiles/per-user/root/channels`, `/root/.nix-channels`, `$HOME/.nix-defexpr/channels`
    #   <repo:nixos/nixpkgs:nixos/modules/config/nix-channel.nix>
    nix.channel.enable = false;

    # environment.stub-ld: populate /lib/ld-linux.so with an object that unconditionally errors on launch,
    # so as to inform when trying to run a non-nixos binary?
    # IMO that's confusing: i thought /lib/ld-linux.so was some file actually required by nix.
    environment.stub-ld.enable = false;

    # `less.enable` sets LESSKEYIN_SYSTEM, LESSOPEN, LESSCLOSE env vars, which does confusing "lesspipe" things, so disable that.
    # it's enabled by default from `<nixos/modules/programs/environment.nix>`, who also sets `PAGER="less"` and `EDITOR="nano"` (keep).
    programs.less.enable = lib.mkForce false;
    environment.variables.PAGER = lib.mkOverride 900 "";  # mkDefault sets 1000. non-override is 100. 900 will beat the nixpkgs `mkDefault` but not anyone else.
    environment.variables.EDITOR = lib.mkOverride 900 "";

    # several packages (dconf, modemmanager, networkmanager, gvfs, polkit, udisks, bluez/blueman, feedbackd, etc)
    # will add themselves to the dbus search path.
    # i prefer dbus to only search XDG paths (/share/dbus-1) for service files, as that's more introspectable.
    # see: <repo:nixos/nixpkgs:nixos/modules/services/system/dbus.nix>
    # TODO: sandbox dbus? i pretty explicitly don't want to use it as a launcher.
    services.dbus.packages = lib.mkForce [
      "/run/current-system/sw"
      # config.system.path
      # pkgs.dbus
      # pkgs.polkit.out
      # pkgs.modemmanager
      # pkgs.networkmanager
      # pkgs.udisks
      # pkgs.wpa_supplicant
    ];

    # systemd by default forces shitty defaults for e.g. /tmp/.X11-unix.
    # nixos propagates those in: <nixos/modules/system/boot/systemd/tmpfiles.nix>
    # by overwriting this with an empty file, we can effectively remove it.
    environment.etc."tmpfiles.d/x11.conf".text = "# (removed by Colin)";

    # see: <nixos/modules/tasks/swraid.nix>
    # it was enabled by default before 23.11
    boot.swraid.enable = lib.mkDefault false;

    # see: <nixos/modules/tasks/bcache.nix>
    # these allow you to use the Linux block cache (cool! doesn't need to be a default though)
    boot.bcache.enable = lib.mkDefault false;

    # see: <nixos/modules/system/boot/kernel.nix>
    # by default, it adds to boot.initrd.availableKernelModules:
    # - SATA: "ahci" "sata_nv" "sata_via" "sata_sis" "sata_uli" "ata_piix" "pata_marvell"
    # - "nvme"
    # - scsi: "sd_mod" "sr_mod"
    # - SD/eMMC: "mmc_block"
    # - USB keyboards: "uhci_hcd" "ehci_hcd" "ehci_pci" "ohci_hcd" "ohci_pci" "xhci_hcd" "xhci_pci" "usbhid" "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat" "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft" "hid_cherry" "hid_corsair"
    # - LVM: "dm_mod"
    # - on x86 only: more keyboard stuff: "pcips2" "atkbd" "i8042"
    #
    # however, including these modules seems relatively *harmless*,
    # and it makes bringup of new systems a bit easier.
    # boot.initrd.includeDefaultModules = lib.mkDefault false;

    # see: <repo:nixos/nixpkgs:nixos/modules/virtualisation/nixos-containers.nix>
    boot.enableContainers = lib.mkDefault false;

    # see: <repo:nixos/nixpkgs:nixos/modules/tasks/lvm.nix>
    # lvm places `pkgs.lvm2` onto PATH, which has like 100 binaries.
    # it is, actually, needed for some userspace tools (cryptsetup). probably just the udev rules. try to reduce this set?
    services.lvm.enable = lib.mkDefault false;
    services.udev.packages = [ pkgs.lvm2.out ];  #< N.B. `lvm2.out` != `lvm2`
    # systemd.packages = [ pkgs.lvm2 ];
    # systemd.tmpfiles.packages = [ pkgs.lvm2.out ];
    # environment.systemPackages = [ pkgs.lvm2 ];

    security.pam.package = suidlessPam;
  };
}
