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
    "i686-linux" = "linux-i386";
    "aarch64-linux" = "linux-aarch64";
    "armv7l-linux" = "linux-armv7l";
  };

  platform =
    if builtins.hasAttr stdenv.system platformMap then
      platformMap.${stdenv.system}
    else
      throw "Unsupported platform: ${stdenv.system}";

  url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip";

  sha256s = {
    "x86_64-linux" = "";
    "i686-linux" = "";
    "aarch64-linux" = "sha256-imp36CgZGQeD4eWf+kPep55sM42lHQvwDobfVV9ija0=";
    "armv7l-linux" = "";
  };

  sha256 = sha256s.${stdenv.system};

  src = fetchzip {
    inherit url sha256;
  };

in
buildFHSEnv {
  inherit pname version;

  runScript = "${src}/${pname}";

  #extraBwrapArgs = [
  #  "--ro-bind /etc/snell /etc/snell"
  #];
  #extraBindMounts = [
  #  { hostPath = "/etc/snell"; mountPoint = "/etc/snell"; isReadOnly = true; }
  #];

  meta = with lib; {
    description = "Snell is a lean encrypted proxy protocol developed by Surge team";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    license = licenses.unfreeRedistributable;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platformMap;
    mainProgram = pname;
  };
}
