{
  sources,
  stdenv,
  cmake,
  pkg-config,
  pcsclite,
  curl,
  nix-update-script,
  lib,
  drivers ? true,
  libeuicc ? true,
}:

let
  inherit (lib) optional;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.lpac) pname version src;

  postPatch = ''
    ln --symbolic --force --verbose ${./git-version.cmake} cmake/git-version.cmake
  '';
  env.LPAC_VERSION = finalAttrs.src.rev;

  cmakeFlags =
    optional drivers "-DLPAC_DYNAMIC_DRIVERS=on"
    ++ optional libeuicc "-DLPAC_DYNAMIC_LIBEUICC=on";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    curl
    pcsclite
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = finalAttrs.pname; };
  };

  meta = with lib; {
    description = "C-based eUICC LPA";
    homepage = "https://github.com/estkme-group/lpac";
    mainProgram = "lpac";
    license = [ licenses.agpl3Plus ] ++ optional libeuicc licenses.lgpl21Plus;
    maintainers = with maintainers; [ yinfeng ];
  };
})
