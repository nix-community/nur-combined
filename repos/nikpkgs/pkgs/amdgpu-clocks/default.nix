{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "amdgpu-clocks";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "sibradzic";
    repo = "amdgpu-clocks";
    rev = "9d1196ef9839233a6f1b8c343e4769d5229c5015";
    sha256 = "+m4qVVySCLvqZjktd2rrSGfqB1z01IdvE4gLztShA5U=";
  };

  nativeBuildInputs = [ pkgs.bash ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    ls
    cp amdgpu-clocks        $out/bin
    cp amdgpu-clocks-resume $out/bin
  '';

  meta = with lib; {
    description = "Tool for playing around with AMD GPU clocks and voltages";
    homepage = "https://github.com/sibradzic/amdgpu-clocks";
    license = licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
