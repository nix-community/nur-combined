{
  fetchFromGitHub,
  stdenv,
  meson,
  ninja,
  libxslt,
  lib,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "run0-wrappers";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "thkukuk";
    repo = "run0-wrappers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZccmOjKy14IAGaYHjDs3wTkY18QU1UYAlN50tvjLQhg=";
  };
  nativeBuildInputs = [
    meson
    ninja
    libxslt
  ];
  mesonFlags = [
    (lib.mesonEnable "man" false)
    (lib.mesonOption "sysconfdir" "etc")
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wrappers for systemd's run0 to replace pkexec, su, and sudo";
    homepage = "https://github.com/thkukuk/run0-wrappers";
    changelog = "https://github.com/thkukuk/run0-wrappers/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
