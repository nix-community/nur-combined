{ stdenv, fetchFromGitHub, requireFile, python3, pkg-config
, audiofile, SDL2, hexdump, compileFlags ? [], region ? "us"
, baseRom ? requireFile {
    name = "baserom.${region}.z64";
    message = ''
      This nix expression requires that baserom.${region}.z64 is
      already part of the store. To get this file you can dump your Super Mario 64 cartridge's contents
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
      Note that if you are not using a US baserom, you must overwrite the "region" attribute with either "eu" or "jp".
    '';
    sha256 = {
      "us" = "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91";
      "eu" = "c792e5ebcba34c8d98c0c44cf29747c8ee67e7b907fcc77887f9ff2523f80572";
      "jp" = "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317";
    }.${region};
  }
}:

stdenv.mkDerivation rec {
  pname = "sm64pc";
  version = "unstable-2020-05-19";

  src = fetchFromGitHub {
    owner = "sm64pc";
    repo = "sm64pc";
    rev = "c18e70f44eaf628f5795002c29166bbfc4835238";
    sha256 = "1vjk5g3jkrv21hwv13c7qf1disdv486sx6inn073ijx7g63hyzag";
  };

  nativeBuildInputs = [ python3 pkg-config ];
  buildInputs = [ audiofile SDL2 hexdump ];

  inherit baseRom;

  makeFlags = [ "VERSION=${region}" ] ++ compileFlags;

  preBuild = ''
    patchShebangs extract_assets.py
    cp $baseRom ./baserom.${region}.z64
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/${region}_pc/sm64.${region}.f3dex2e $out/bin/sm64pc
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/sm64pc/sm64pc";
    description = "Super Mario 64 port based off of decompilation";
    longDescription = "Super Mario 64 port based off of decompilation. Note that you must supply a baserom yourself to extract assets from";
    license = licenses.unfree;
    maintainers = with maintainers; [ ivar ];
    platforms = platforms.linux;
  };
}
