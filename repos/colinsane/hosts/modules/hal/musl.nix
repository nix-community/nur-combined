{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.musl;
in
{
  options = {
    sane.hal.musl.enable = (lib.mkEnableOption "tweaks required on a musl libc system") // {
      default = pkgs.stdenv.hostPlatform.isMusl;
    };
  };

  # securityWrappers use pkgsStatic, but `pkgsMusl.pkgsStatic.stdenv` fails to build.
  # patch securityWrappers to use normal `pkgs`.
  # XXX(2026-01-20): this causes infinite recursion => done via `overlays/musl.nix` instead.
  # disabledModules = [
  #   "security/wrappers/default.nix"
  # ];
  # imports = [
  #   (import "${pkgs.path}/nixos/modules/security/wrappers/default.nix" {
  #     pkgs = pkgs // {
  #       pkgsStatic = pkgs;
  #     };
  #   })
  # ];

  config = lib.mkIf cfg.enable {
    services.dbus.implementation = "dbus";  #< 2026-04-26 - 2026-05-23: `pkgsMusl.dbus-broker` fails to build

    documentation.nixos.enable = false;  #< fails building `nix-expr`

    hardware.amdgpu.opencl.enable = false;  #< fails build rocmPackages.*

    environment.sessionVariables.VK_LOADER_DRIVERS_DISABLE = "*nouveau*";  #< 2026-03-02: fixes gtk apps to not segfault. unsure if musl, or all nvidia
    sane.users.colin.environment.VK_LOADER_DRIVERS_DISABLE = "*nouveau*";

    # sane.programs.alsa-utils.enableFor = { system = false; user.colin = false; };  #< 2026-01-24: blocked on gtk4 -> ... -> gdb,netpbm,...
    # sane.programs.audacity.enableFor.user.colin = false;  #< 2026-02-03: "/build/source/libraries/lib-sqlite-helpers/sqlite/Statement.h:55:4: error: ‘int64_t’ does not name a type"
    sane.programs.avahi.enableFor.user.colin = false;  #< 2026-01-25: causes `nss-mdns` to be on nssModules; not supported. long-term: enable mdns via a dns proxy -- not nss
    sane.programs.brave.enableFor.user.colin = false;  #< 2026-01-29: links against libgcc_s.so.1, etc: lots of undefined symbols during installCheckPhase
    sane.programs.celeste64.enableFor.user.colin = false;  #< 2026-01-26 - 2026-05-23: blocked on dotnet-sdk
    sane.programs.ctags-lsp.enableFor = { system = false; user.colin = false; };  #< 2026-02-26 - 2026-05-23: blocked on universal-ctags ("Failed tests ... sandbox*")
    # sane.programs.discord.enableFor.user.colin = false; #< 2026-01-29: links against libc.so.6, etc.
    sane.programs.docsets.enableFor = { system = false; user.colin = false; }; #< 2026-01-24: fails building `nix-expr`
    sane.programs.element-desktop.enableFor.user.colin = false;  #< 2026-02-15: blocked by electron
    # sane.programs.dtrx.enableFor.user.colin = false; #< 2026-01-24 - 2026-02-14: blocked on rpm: `rpmio/rpmglob.c:84:15: error: ‘GLOB_BRACE’ undeclared`
    # sane.programs.exiftool.enableFor.user.colin = false;  # its many perl deps fail to cross compile
    # sane.programs.fftest.enableFor = { system = false; user.colin = false; };  #< 2026-01-24: blocked on gtk4 -> ... -> gdb,netpbm,...
    # sane.programs.gimp.enableFor.user.colin = false;  #< 2026-02-03: fails to create docs: "Failed to create the data directory '/homeless-shelter/.local/share': Permission denied"
    sane.programs.gnome-frog.enableFor.user.colin = false;  #< 2026-03-27 - 2026-05-23: blocked on zbar
    sane.programs.itgmania.enableFor.user.colin = false;  #< 2026-02-03 - 2026-05-23: fails build "error: conflicting declaration of C function ‘void __assert_fail(...)"
    sane.programs.krita.enableFor.user.colin = false;  #< 2026-02-03 - 2026-05-23: blocked on opencolorio (which fails tests)
    sane.programs.libreoffice.enableFor.user.colin = false;  #< 2026-02-03: blocked on rhino -> gradle: "libc.so.6 -> not found"
    sane.programs.losslesscut.enableFor.user.colin = false;  #< 2026-05-26: blocked by electron_39
    sane.programs.mepo.enableFor.user.colin = false;  #< 2026-01-29 - 2026-05-23: fails installPhase: "Failed loading SDL3 library."
    sane.programs.newsflash.enableFor.user.colin = false;  #< 2026-05-23: fails build "error[E0425]: cannot find function `malloc_trim` in crate `libc`"
    # sane.programs.newelle.enableFor.user.colin = false;  #< 2026-02-03: blocked on anthropic -> ... -> arrow-cpp
    # sane.programs.nix.packageUnwrapped = lib.mkForce pkgs.nixVersions.latest;  #< 2026-02-28 - 2026-03-27: `pkgsMusl.lix` fails several unit tests right now
    sane.programs.nix.packageUnwrapped = lib.mkForce pkgs.pkgsStatic.lixPackageSets.latest.lix;  #< 2026-02-28 - 2026-03-27: `pkgsMusl.lix` fails several unit tests right now
    # sane.programs.nix-index.enableFor.user.colin = false;  #< 2026-01-24: `nix-main` fails compile
    # sane.programs.nixd.enableFor = { system = false; user.colin = false; };  #< 2026-01-24: `nix-expr` fails compile
    # sane.programs.nixpkgs-hammering.enableFor.user.colin = false;  #< 2026-01-24: `nix-main` fails compile
    # sane.programs.nixpkgs-review.enableFor.user.colin = false;  #< 2026-01-24: `nix-main` fails compile
    sane.programs.openscad-lsp.enableFor = { system = false; user.colin = false; };  #< 2026-01-24 - 2026-05-23: fails rust linking
    sane.programs.papers.enableFor.user.colin = false;  #< 2026-03-01: papers crashes on launch (even just `papers --version`)
    sane.programs.guiBaseApps.suggestedPrograms = [ "evince" ];  # instead of papers
    # sane.programs.python3-repl.enableFor = { system = false; user.colin = false; };  #< 2026-01-24: fails building xsimd
    sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # blocked on dotnet-sdk
    # sane.programs.nix-tree.enableFor.user.colin = false;  #< 2026-01-24: blocked on vector
    # sane.programs.nfs-utils.enableFor.system = false; #< 2026-01-24 - 2026-02-02: fails build
    # sane.programs."sane-scripts.tag-media".enableFor.user.colin = false;  #< 2026-02-02: blocked on python3Packages.aiohttp
    # sane.programs."sane-scripts.wipe".enableFor.user.colin = false;  #< 2026-01-24: blocked on libsecret -> gtk4 -> ... -> gdb,netpbm,...
    sane.programs.resources.enableFor.user.colin = false;  #< 2026-02-09 - 2026-03-27: "libc::ioctl(fd, ioctl_cmd, &mut get_info): expected i32, found u64"
    # sane.programs.signal-desktop.enableFor.user.colin = false;  #< 2026-02-03: blocked on libsignal-node rust: "Error[E0463]: can't find crate for `core`". also `signal-rtc`
    sane.programs.sm64coopdx.enableFor.user.colin = false;  #< 2026-01-29: `src/pc/crash_handler.c:157:10: fatal error: execinfo.h: No such file or directory`
    sane.programs.steam.enableFor.user.colin = false;
    sane.programs.supertux.enableFor.user.colin = false;  #< 2026-03-17: `error_handler.cpp:53:10: fatal error: execinfo.h: No such file or directory`
    # sane.programs.tor-browser.enableFor.user.colin = false;  #< 2026-02-03: "error: auto-patchelf could not satisfy dependency libdl.so.2 wanted by firefox.real", etc
    # sane.programs.visidata.enableFor.user.colin = false;  #< 2026-02-14: blocked on arrow-cpp
    # sane.programs.wireshark.enableFor.user.colin = false;  #< 2026-02-19: blocked on spandsp3 tests
    sane.programs.zelda64recomp.enableFor.user.colin = false;  #< 2026-01-28: blocked on directx-shader-compiler
  };
}
