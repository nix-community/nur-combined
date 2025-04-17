{
  sources,
  lib,
  nix-update-script,
  stdenv,
  cmake,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.metee) pname version src;

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "C library to access CSE/CSME/GSC firmware via a MEI interface";
    homepage = "https://github.com/intel/metee";
    license = lib.licenses.asl20;
    changelog = "https://github.com/intel/metee/releases/tag/${finalAttrs.version}";
  };
})
