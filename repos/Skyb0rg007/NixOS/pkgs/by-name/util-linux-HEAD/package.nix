{
  lib,
  util-linux,
  fetchFromGitHub,
  asciidoctor,
  autoconf,
  automake,
  bison,
  flex,
  gettext,
  libtool,
  shadow,
  versionCheckHook,
  nix-update-script,
}:

(util-linux.override { translateManpages = false; }).overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "util-linux-HEAD";
    version = "2.43-devel-unstable-2026-11-11";

    src = fetchFromGitHub {
      owner = "util-linux";
      repo = "util-linux";
      rev = "d6abbbab2cf284597720b8426fdd67c5cef7c9f8";
      hash = "sha256-j04Fx0fe07cfo9Pn+Cp79UCAPu9gmpkIbV5Mfy/2dXE=";
    };

    # Replaces nixpkgs' postPatch, since its sys-utils/eject.c substitution no
    # longer applies: eject now unmounts via libmount instead of /bin/umount.
    postPatch = ''
      patchShebangs autogen.sh po/update-potfiles tests/run.sh tools

      # The version is normally derived from `git describe`
      echo ${lib.escapeShellArg finalAttrs.version} > .tarball-version

      # fix `mount -t` tab completion
      substituteInPlace bash-completion/{blkid,mount,umount} \
        --replace-fail "/lib/modules" "/run/booted-system/kernel-modules/lib/modules"

      substituteInPlace include/pathnames.h \
        --replace-fail "/bin/login" "${shadow}/bin/login"
    '';

    # Release tarballs ship the generated build system and man pages
    preConfigure = ''
      ./autogen.sh
    '';

    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
      asciidoctor
      autoconf
      automake
      bison
      flex
      gettext
      libtool
    ];

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgram = "${placeholder "bin"}/bin/lsblk";

    passthru = prevAttrs.passthru // {
      tests = { };
      updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };
    };

    meta = prevAttrs.meta // {
      description = "Set of system utilities for Linux, built from git master";
      homepage = "https://github.com/util-linux/util-linux";
      changelog = "https://github.com/util-linux/util-linux/commits/${finalAttrs.src.rev}";
      maintainers = [ lib.maintainers.skyesoss ];
      teams = [ ];
      platforms = lib.platforms.linux;
    };
  }
)
