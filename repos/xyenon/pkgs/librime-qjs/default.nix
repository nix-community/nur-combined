{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "1.2.0-unstable-2025-09-09";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "12636b1ec7d6103a02e50c7d5eff1793b1d36949";
    fetchSubmodules = true;
    hash = "sha256-APegQHmadMaV4Lwl/cPTZsZKvO6MY47YyvojIoQRSBc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp --archive --verbose src/ tests/ thirdparty/ $out
    install --mode=644 --verbose --target-directory=$out CMakeLists.txt LICENSE readme.md

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
    tagFormat = "v*";
  };

  meta = with lib; {
    description = "Bring a fresh JavaScript plugin ecosystem to the Rime Input Method Engine";
    homepage = "https://github.com/HuangJian/librime-qjs";
    license = licenses.bsd3;
    maintainers = with maintainers; [ xyenon ];
  };
}
