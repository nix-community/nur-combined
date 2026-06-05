# strictly *decrease* the scope of the default nixos installation/config

{ config, lib, pkgs, ... }:
let
  # openpam = pkgs.openpam.overrideAttrs (upstream: {
  #   configureFlags = (upstream.configureFlags or []) ++ [
  #     "--with-pam-unix"
  #   ];
  #   # postFixup = (upstream.postFixup or "") + ''
  #   #   # nixpkgs `security.pam` module expects modules to be at $out/lib/security/pam_*.so
  #   #   ln -s . $out/lib/security
  #   # '';
  # });

  # tcb = pkgs.tcb.overrideAttrs (upstream: {
  #   # in order for pam_tcb to be a drop-in replacement for pam_unix,
  #   # it needs to behave as if it'd been given the `shadow` setting.
  #   postPatch = (upstream.postPatch or "") + ''
  #     substituteInPlace pam_tcb/support.c \
  #       --replace-fail 'if (on(UNIX_SHADOW))' 'if (true)'
  #   '';
  # });

  suidlessPam = pkgs.pam.overrideAttrs (upstream: {
    postPatch = let
      # nixpkgs' pam hardcodes unix_chkpwd path to the /run/wrappers one,
      # but i don't want the wrapper, so undo that.
      # ideally i would patch this via an overlay, but pam is in the bootstrap so that forces a full rebuild.
      # see: <repo:nixos/nixpkgs:pkgs/by-name/li/linux-pam/package.nix>
      chkpwd = "$out/bin/unix_chkpwd";
      #
      # or, use tcb-style password checking: i.e. passwords for each user are in /etc/tcb/$user/shadow.
      # but this seems to not actually work.
      # chkpwd = "${pkgs.tcb}/libexec/chkpwd/tcb_chkpwd";
    in (upstream.postPatch or "") + ''
      substituteInPlace modules/module-meson.build --replace-fail \
        "/run/wrappers/bin/unix_chkpwd" "${chkpwd}"
    '';

    # linux-pam is a mess; honestly `openpam` would be better to use system-wide.
    # but applications are linked against `linux-pam`, so we can't.
    # instead, swap just `pam_unix.so` for the `openpam` implementation;
    # it uses bog-standard `getpwnam` under-the-hood, which is enough to get what i need: tcb (via nss).
    # postInstall = (upstream.postInstall or "") + ''
    #   rm $out/lib/security/pam_unix.so*
    #   cp ${openpam}/lib/pam_unix.so* $out/lib/security
    # '';

    # i could update all /etc/shadow-based PAM consumers to use `pam_tcb.so`, so they get /etc/tcb/$user/shadow
    # -- or i could be lazy and swap it out here.
    # postInstall = (upstream.postInstall or "") + ''
    #   rm $out/lib/security/pam_unix.so*
    #   ln -s ${tcb}/lib/security/pam_tcb.so $out/lib/security/pam_unix.so
    # '';

    # XXX(2026-01-01): `getspnam` is the libc function which queries /etc/shadow, etc, directly,
    # rather than (or before falling back to) the SUID unix_chkpwd.
    # for glibc, it obeys /etc/nsswitch.conf rather than *just* consulting /etc/shadow.
    # for musl, it consults /etc/shadow and /etc/tcb/$user/shadow.
    # this flag isn't present in pam 1.7.1, but once released i could likely drop pam_tcb by enabling it.
    # mesonFlags = (upstream.mesonFlags or []) ++ [
    #   (lib.mesonEnable "pam_unix-try-getspnam" true)
    # ];
  });
  # `mkDefault` is `mkOverride 1000`.
  # `mkOverrideDefault` will override `mkDefault` values, but not ordinary values.
  mkOverrideDefault = lib.mkOverride 900;
in
{
  # patch systemd module to not populate /etc/nsswitch.conf
  # (i.e. system.{nssDatabases,nssModules}, processed by <repo:nixos/nixpkgs:nixos/modules/config/nsswitch.nix>).
  # nsswitch.conf is a glibc-only thing, and i'd like to preserve compatibilty with musl, go, etc.
  disabledModules = [
    "system/boot/systemd.nix"
  ];
  imports = [
    ({ config, lib, pkgs, utils, ... }@moduleArgs:
      let
        # base = lib.modules.importApply "${pkgs.path}/nixos/modules/system/boot/systemd.nix" moduleArgs;
        base = import "${pkgs.path}/nixos/modules/system/boot/systemd.nix" moduleArgs;
      in {
        options.systemd = {
          inherit (base.options.systemd)
            additionalUpstreamSystemUnits
            automounts
            ctrlAltDelUnit
            defaultUnit
            enableStrictShellChecks
            generators
            generatorEnvironment
            generatorPath
            globalEnvironment
            managerEnvironment
            mounts
            package
            packages
            paths
            services
            settings
            shutdown
            sleep
            slices
            sockets
            suppressedSystemUnits
            targets
            timers
            units
            ;
        };
        # inherit (base.systemd) config;
        config = {
          # TODO: port to `mkTypedMerge`
          inherit (base.config)
            boot
            environment
            security
            services
            system
            systemd
            users
            warnings
          ;
        } // {
          system = base.config.system // {
            nssDatabases = {};
            nssModules = [];
          };
        };
      }
    )
  ];

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

  options.environment.corePackages = lib.mkOption {
    # defined:  <repo:nixos/nixpkgs:nixos/modules/config/system-path.nix>
    # - it's 31 "corePackages", with no explanation of why they're "required"...
    # - most of these can be safely removed without breaking the *boot*,
    # - but some core system services DO implicitly depend on them.
    # TODO: see which more of these i can remove (or shadow/sandbox)
    apply = let
      pkgsToRemove = [
        pkgs.wirelesstools  #< assigned: <repo:nixos/nixpkgs:nixos/modules/tasks/network-interfaces.nix>
        # pkgs.stdenv.cc.libc #< assigned: <repo:nixos/nixpkgs:nixos/modules/config/system-path.nix>
        # config.programs.ssh.package  #< assigned: <repo:nixos/nixpkgs:nixos/modules/programs/ssh.nix>
      ];
      lowPrioPkgsToRemove = map (pkg: lib.setPrio ((pkg.meta.priority or lib.meta.defaultPriority) + 3) pkg) [
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
        # pkgs.mkpasswd
        pkgs.procps
        # pkgs.su
        # pkgs.time
        # pkgs.util-linux
        # pkgs.which
        # pkgs.zstd
      ];
    in
      lib.filter (p: !(lib.elem p (pkgsToRemove ++ lowPrioPkgsToRemove)));
  };

  options.environment.systemPackages = lib.mkOption {
    apply = let
      conveniencePackagesToRemove = [
        config.boot.kernelPackages.cpupower  # <repo:nixos/nixpkgs:nixos/modules/tasks/cpu-freq.nix> places it on PATH for convenience if powerManagement.cpuFreqGovernor is set
        pkgs.kbd  # <repo:nixos/nixpkgs:nixos/modules/config/console.nix>  places it on PATH as part of console/virtual TTYs, but probably not needed unless you want to set console fonts
        pkgs.nixos-firewall-tool  # <repo:nixos/nixpkgs:nixos/modules/services/networking/firewall.nix>  for end-user management of the firewall? cool but doesn't cross-compile
      ];
    in lib.filter (p: ! lib.elem p (conveniencePackagesToRemove));
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

    system.tools.nixos-generate-config.enable = false;
  };
}
