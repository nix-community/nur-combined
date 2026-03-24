{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "vivecraft";
  version = "1.3.6-1";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://cdn.modrinth.com/data/o8TGTrsR/versions/vK2WTkaR/Vivecraft-Spigot-Extension-${version}.jar";
      sha256 = "1w2845yd239f8plgj2cvj24rsmay1zrsms9rd49aq4yf0c5f82vz";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/Vivecraft/Vivecraft-Spigot-Extension";
    description = "Official Vivecraft server-side Spigot extension for VR support.";
    maintainers = with maintainers; [zeratax];
  };
}
