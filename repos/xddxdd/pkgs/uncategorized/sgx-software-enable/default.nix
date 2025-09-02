{
  stdenv,
  sources,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.sgx-software-enable) pname version src;

  installPhase = ''
    runHook preInstall

    install -Dm755 sgx_enable $out/bin/sgx_enable
    ln -sf $out/bin/sgx_enable $out/bin/sgx-software-enable

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Application to enable Intel SGX on Linux systems";
    homepage = "https://github.com/intel/sgx-software-enable";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sgx-software-enable";
  };
})
