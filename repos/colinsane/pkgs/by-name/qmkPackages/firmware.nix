# after building a firmware image (.hex file),
# flash it to a plugged-in keyboard using wally:
# - `nix-build -A qmkPackages.ergodox_ez_glow_sane`
# - `wally-cli ./result/share/qmk/ergodox_ez_glow_sane.hex`
{
  fetchFromGitHub,
  nix-update-script,
  qmk,
  stdenv,
  keyboard ? "all",
  keymap ? "all",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qmk-firmware-${keyboard}-${keymap}";
  version = "0.25.9";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = finalAttrs.version;
    hash = "sha256-M0kLGbte1wq5teD56IFd8uWCIvpra8dz2b0bjxlTzx0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qmk
  ];

  makeFlags = [ "${keyboard}:${keymap}" ];
  env.QMK_USERSPACE = "${./userspace}";

  # seems to still use just one core, so don't try to build all keyboards unless you hate yourself.
  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/share/qmk
    install -Dm644 *.hex $out/share/qmk
  '';
})
