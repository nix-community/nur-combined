{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "1.2.0-unstable-2025-05-03";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "5f17ba18ef52bd2ddd74ff70c4d8e57cce5c9cce";
    fetchSubmodules = true;
    hash = "sha256-7WoldwefkN/8NMROMYQGPcVt3stxsyge3uI8pqFj1v4=";
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
