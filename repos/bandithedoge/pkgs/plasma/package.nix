{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "Dimethoxy";
    repo = "Plasma";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XfHYGZRgZ2fuVIasp4CSnwmO/MW254b6fgFAQmVug2Q=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Plasma.jucer";

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Asymmetrical Distortion Audio Plugin";
    homepage = "https://github.com/Dimethoxy/Plasma";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
