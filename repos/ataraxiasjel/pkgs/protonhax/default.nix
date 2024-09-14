{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "protonhax";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "jcnils";
    repo = pname;
    rev = version;
    hash = "sha256-5G4MCWuaF/adSc9kpW/4oDWFFRpviTKMXYAuT2sFf9w=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp protonhax $out/bin

    runHook postInstall
  '';

  postFixup = ''
    patchShebangs --build $out/bin protonhax
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Program to help executing outside programs in proton";
    homepage = "https://github.com/aoleg94/protonhax";
    platforms = [ "x86_64-linux" ];
    license = licenses.bsd3;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "protonhax";
  };
}
