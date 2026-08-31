{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sgx-software-enable";
  version = "1.0-unstable-2023-01-06";
  src = fetchFromGitHub {
    owner = "intel";
    repo = "sgx-software-enable";
    rev = "7977d6dd373f3a14a615ee9be6f24ecd37c0b43d";
    hash = "sha256-xBmFCrnNQq0xKwv7irJFN8YRfBCLmSxtak5dtHFv/xk=";
  };
  installPhase = ''
    runHook preInstall

    install -Dm755 sgx_enable $out/bin/sgx_enable
    ln -sf $out/bin/sgx_enable $out/bin/sgx-software-enable

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/intel/sgx-software-enable";
    tagPrefix = "v";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Application to enable Intel SGX on Linux systems";
    homepage = "https://github.com/intel/sgx-software-enable";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sgx-software-enable";
  };
})
