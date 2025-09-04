{
  lib,
  stdenv,
  fetchzip,
  buildFHSEnv,
}:

let
  pname = "snell-server";
  version = "5.0.0";

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    # "i686-linux" = "linux-i386";
    "aarch64-linux" = "linux-aarch64";
    # "armv7l-linux" = "linux-armv7l";
  };

  platform =
    if builtins.hasAttr stdenv.system platformMap then
      platformMap.${stdenv.system}
    else
      throw "Unsupported platform: ${stdenv.system}";

  url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip";

  sha256s = {
    "x86_64-linux" = "0sr49as173q3x8n410zhm0qm2msbxkyy3pzqszg96pzpqi2631zw";
    # "i686-linux" = "sha256-DDDDDD..."; # replace with correct format
    "aarch64-linux" = "sha256-/eNcHEjRTgjQwdHkkhgnXcNfZ3PkrWXgS2C4O5JNc5w=";
    # "armv7l-linux" = "sha256-BBBBBB...";
  };

  sha256 = sha256s.${stdenv.system};

  src = fetchzip {
    inherit url sha256;
    stripRoot = false;
  };

in
buildFHSEnv {
  inherit pname version;

  runScript = "${src}/snell-server";

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src/$pname $out/bin/$pname
  '';

  meta = with lib; {
    description = "Snell is a lean encrypted proxy protocol developed by Surge team";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    license = licenses.unfreeRedistributable;
    sourceProvenance = sourceTypes.binaryNativeCode;
    platforms = builtins.attrNames platformMap;
    mainProgram = pname;
  };
}
