{
  sources,
  version,
  lib,
  stdenv,
  pkg-config,
  wine64,
  pipewire,
}:
stdenv.mkDerivation (_finalAttrs: {
  inherit (sources) pname src;
  inherit version;

  nativeBuildInputs = [
    pkg-config
    wine64
  ];

  buildInputs = [
    pipewire
  ];

  strictDeps = true;
  __structuredAttrs = true;

  makeFlags = [
    "CC=${lib.getExe stdenv.cc}"
    "WINDOWSINC=${lib.getDev wine64}/include/wine/windows"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r lib $out/

    runHook postInstall
  '';

  meta = {
    description = "ASIO to PipeWire in Wine";
    homepage = "https://github.com/golfiros/pwasio";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };
})
