{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "1.3.0-unstable-2026-03-09";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "c8406c8cf33a72eefaeaebbc77ef536490055e18";
    fetchSubmodules = true;
    hash = "sha256-BMT/WX8jSfMvpJBaQpq+jYDB0XVC5aUqbJvR08AUxOw=";
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
