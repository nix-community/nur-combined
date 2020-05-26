{ stdenv, fetchFromGitHub, requireFile, python3, pkg-config
, audiofile, SDL2, hexdump, makeFlags ? [] }:

stdenv.mkDerivation rec {
  pname = "sm64pc";
  version = "unstable-2020-05-19";

  src = fetchFromGitHub {
    owner = "sm64pc";
    repo = "sm64pc";
    rev = "c18e70f44eaf628f5795002c29166bbfc4835238";
    sha256 = "1vjk5g3jkrv21hwv13c7qf1disdv486sx6inn073ijx7g63hyzag";
  };

  baseRom = requireFile {
    name = "baserom.us.z64";
    message = ''
      This nix expression requires that baserom.us.z64 is
      already part of the store. To get this file you can dump your US Super Mario 64 cartridge's contents
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91";
  };

  nativeBuildInputs = [ python3 pkg-config ];
  buildInputs = [ audiofile SDL2 hexdump ];

  inherit makeFlags;

  preBuild = ''
    substituteInPlace extract_assets.py --replace "/usr/bin/env python3" "${python3}/bin/python3"
    cp $baseRom ./baserom.us.z64
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/us_pc/sm64.us.f3dex2e $out/bin/sm64pc
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/sm64pc/sm64pc";
    description = "Super Mario 64 port based off of decompilation";
    longDescription = "Super Mario 64 port based off of decompilation. Note that you must supply a US baserom yourself to extract assets from";
    license = licenses.publicDomain;
    maintainers = with maintainers; [ ivar ];
    platforms = platforms.linux;
  };
}
