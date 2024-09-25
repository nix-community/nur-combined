{
  stdenv,
  sources,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.sgx-software-enable) pname version src;

  installPhase = ''
    runHook preInstall

    install -Dm755 sgx_enable $out/bin/sgx_enable
    ln -sf $out/bin/sgx_enable $out/bin/sgx-software-enable

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "This application will enable Intel SGX on Linux systems where the BIOS supports Intel SGX, but does not provide an explicit option to enable it. These systems can only enable Intel SGX via the \"software enable\" procedure.";
    homepage = "https://github.com/intel/sgx-software-enable";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
