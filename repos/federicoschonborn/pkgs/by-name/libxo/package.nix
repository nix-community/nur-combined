{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libslax,
  validatePkgConfig,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxo";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "libxo";
    tag = finalAttrs.version;
    hash = "sha256-ElSxegY2ejw7IuIMznfVpl29Wyvpx9k1BdXregzYsoQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libslax # slax-config
  ];

  buildInputs = [
    libslax
  ];

  strictDeps = true;

  nativeInstallCheckInputs = [ validatePkgConfig ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "xo";
    description = "Library for emitting text, XML, JSON, or HTML output";
    homepage = "https://github.com/Juniper/libxo";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    pkgConfigModules = [ "libxo" ];
  };
})
