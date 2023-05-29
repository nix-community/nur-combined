{ stdenv
, lib
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  name = "ripcord-patcher";
  version = "v0.4.4";

  src = fetchurl {
    url = "https://github.com/geniiii/patcher/releases/download/${version}/patcher-linux-x64";
    sha256 = "0wh04wxahv6jm9mpvh9cx7grjm61cjzjlwvdlbv0cx3ahk1gsyhm";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ripcord-patcher-linux-x64
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "Ripcord binary patcher";
    homepage = "https://github.com/geniiii/patcher/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
