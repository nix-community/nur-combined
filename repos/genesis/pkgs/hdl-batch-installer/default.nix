{ lib, stdenv, fetchFromGitHub, codeblocks }:

stdenv.mkDerivation rec {
  version = "unstable-2021-05-03";
  pname = "hdl-batch-installer";

  src = fetchFromGitHub {
    owner = "israpps";
    repo = "HDL-Batch-installer";
    rev = "e38180f71a87ab57daa29ac877a17a353d920026";
    sha256 = "sha256-TTLNtUs/mOCgYnEDEbzDxt5Eb6zlgUm9tY2VH38ojzg=";
  };

  buildInputs = [ codeblocks ];

  buildPhase = ''
   #codeblocks --build HDL_Batch_installer.cbp  --no-splash-screen
   g++ ./classes/hdl_silent.cpp
   g++ ./HDL_Batch_installerApp.cpp
   g++ ./HDL_Batch_installerMain.cpp

  '';

  installPhase = ''
    install -Dm755 HDL-Batch-installer -t $out/bin
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    broken = true;
    description = "GUI for hdl-dump";
    platforms = platforms.linux;
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
  };
}
