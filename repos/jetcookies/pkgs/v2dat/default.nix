{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {

  pname = "v2dat";
  version = "0-unstable-2022-12-15";

  src = fetchFromGitHub {
    owner = "urlesistiana";
    repo = "v2dat";
    rev = "47b8ee51fb528e11e1a83453b7e767a18d20d1f7";
    hash = "sha256-dJld4hYdfnpphIEJvYsj5VvEF4snLvXZ059HJ2BXwok=";
  };

  vendorHash = "sha256-ndWasQUHt35D528PyGan6JGXh5TthpOhyJI2xBDn0zI=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Cli tool that can unpack v2ray data packages (also known as geoip.dat and geosite.dat) to text files";
    homepage = "https://github.com/urlesistiana/v2dat";
    license = lib.licenses.gpl3Only;
    mainProgram = "v2dat";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
