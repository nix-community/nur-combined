{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cchorus";
  version = "2.2.0";
  src = fetchFromGitHub {
    owner = "SpotlightKid";
    repo = "cchorus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-anOkkPHj5waCdenGD48IjsXEq4hE2Z1l9QTumOaohrE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postPatch = ''
    patchShebangs dpf/utils/generate-ttl.sh
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Versatile stereo chorus, multi-format audio effect plugin";
    homepage = "https://github.com/SpotlightKid/cchorus";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
