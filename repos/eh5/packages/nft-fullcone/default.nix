{ lib
, pkgs
, stdenv
, kernel ? pkgs.linux_latest
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "nft-fullcone";
  version = "unstable-2023-02-26";
  src = fetchFromGitHub {
    owner = "fullcone-nat-nftables";
    repo = name;
    rev = "5a21ca29b7da429174951d1801a9681a25982d10";
    sha256 = "sha256-DpbLiNtS0sY0gEnGImQ84/5GXGtwMdd6/K6JNJaFkow=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "-C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)/src"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];

  meta = with lib; {
    description = "nftables fullcone expression kernel module";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
