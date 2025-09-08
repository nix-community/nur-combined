{
  swaylock,
  fetchFromGitHub,
  replaceVars,
  fprintd,
  dbus,
  nix-update-script,
}:

swaylock.overrideAttrs (attrs: {
  pname = "swaylock-fprintd";
  version = "0-unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "SL-RU";
    repo = "swaylock-fprintd";
    rev = "536d9dff795eb85720fc942da13e93bebea9f5fa";
    hash = "sha256-M19RR1+5oMTdPbC/GwqjpKnnNl30MLDlCkaRY/WMHx4=";
  };

  patches = [
    (replaceVars ./fprintd.patch {
      inherit fprintd;
    })
  ];

  buildInputs = attrs.buildInputs ++ [
    dbus
    fprintd
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
