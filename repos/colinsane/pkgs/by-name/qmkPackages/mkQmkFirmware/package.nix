# N.B.: qmk build is *very* finnicky. there are several variations, especially when it comes to out-of-tree keymaps:
# - <https://github.com/flokli/keyboards/blob/wip-multitouch-experiment/keyboards/dilemma/default.nix>
# - <https://github.com/agustinmista/nixcaps>
#
# qmk has the idea of a "userspace" -- i.e. placing keymaps *outside* of qmk_firmware,
# however in practice it *does not work* reliably (e.g. doesn't work for ergodox_ez/glow).
# - <https://github.com/qmk/qmk_userspace>
#
{
  fetchFromGitHub,
  lib,
  qmk,
  rsync,
  stdenv,
}:
{
  keyboard ? "all",
  keymap ? "default",
  # path to a srcroot for the userspace component
  # userspace/
  # └── keyboards/
  #     └── ergodox_ez/
  #         └── keymaps/
  #             └── sane/
  #                 ├── keymap.c
  #                 └── rules.mk
  userspace ? null,
  ...
}@args:
let
  extraDrvAttrs = lib.removeAttrs args [
    "keyboard"
    "keymap"
    "userspace"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qmk-firmware-${keyboard}-${keymap}";
  version = "0.32.9";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = finalAttrs.version;
    hash = "sha256-xuJbhqyrO8+DGWzzG1qLzByXQyHU7oB/6HW/sg7ZiZ4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    rsync
    qmk
    # (python3.withPackages (ps: [ ps.appdirs ]))
  ];

  makeFlags = [ "${keyboard}:${keymap}" ];

  # env = {
  #   SKIP_GIT = true;
  #   SKIP_VERSION = true;
  # };

  # seems to still use just one core, so don't try to build all keyboards unless you hate yourself.
  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs util/uf2conv.py
  '' + lib.optionalString (userspace != null) ''
    # XXX: `export QMK_USERSPACE={userspace}` SHOULD work instead, but does not.
    rsync -rv ${userspace}/keyboards/ ./keyboards/
  '';

  # alternatively to `makeFlags = [ "${keyboard}:${keymap}" ];`:
  # buildPhase = ''
  #   runHook preBuild
  #   qmk compile -kb "${keyboard}" -km "${keymap}"
  #   runHook postBuild
  # '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/qmk
    install -Dm644 *.hex *.elf *.uf2 $out/share/qmk

    runHook postInstall
  '';
} // extraDrvAttrs)
