{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  quickjs-ng,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "0-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "5e6c4ed2a78aa61fecde96cc3354574e9f3b8fca";
    hash = "sha256-wZ1sGlP7nmoEH0wleoP7ZBUTLcdULxkWuD9HHNc3cro=";
  };

  patches = [ ./CMakeLists.txt.diff ];

  propagatedBuildInputs = [ quickjs-ng ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp --archive --verbose src/ tests/ $out
    install --mode=644 --verbose --target-directory=$out CMakeLists.txt LICENSE readme.md

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Bring a fresh JavaScript plugin ecosystem to the Rime Input Method Engine";
    homepage = "https://github.com/HuangJian/librime-qjs";
    license = licenses.bsd3;
    maintainers = with maintainers; [ xyenon ];
  };
}
