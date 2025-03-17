{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  quickjs-ng,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "librime-qjs";
  version = "0-unstable-2025-03-15";

  src = fetchFromGitHub {
    owner = "HuangJian";
    repo = "librime-qjs";
    rev = "948bd1c7b104c2c4f21eab23393cb35644f392bb";
    hash = "sha256-FQ0zQKtO4eUYS2W7Oo+54UAHKHCYR78QE5NAO+/FcqA=";
  };

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
