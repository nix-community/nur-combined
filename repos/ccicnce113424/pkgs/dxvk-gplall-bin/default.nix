{
  sources,
  version,
  sourceRoot,
  lib,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation (_final: {
  inherit (sources) pname src;
  inherit version sourceRoot;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp *.dll $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Digger1955/dxvk-gplasync-lowlatency";
    description = ''Vulkan 1.3-based implementation of D3D8, D3D9, D3D10, D3D11 with "Async" and "Low Latency" features for real-world usage '';
    license = licenses.zlib;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ccicnce113424 ];
  };
})
