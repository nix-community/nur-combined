{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  libgcc,
  upx,
}:

let
  pname = "snell-server";
  version = "5.0.1";

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "i686-linux" = "linux-i386";
    "aarch64-linux" = "linux-aarch64";
    "armv7l-linux" = "linux-armv7l";
  };

  system = stdenv.hostPlatform.system;

  platform = platformMap.${system} or (throw "Unsupported platform: ${system}");

  url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip";

  # to get the hash, open nix repl
  # pkgs = import <nixpkgs> {}
  # builtins.readDir (pkgs.fetchzip { url = "https://dl.nssurge.com/snell/snell-server-v5.0.1-linux-armv7l.zip"; })
  sha256s = {
    "x86_64-linux" = "sha256-J2kRVJRC0GhxLMarg7Ucdk8uvzTsKbFHePEflPjwsHU=";
    "i686-linux" = "sha256-x2OZjsjm8Oo1ab3tEJuktFcGkHgps0BWlH9XWvtzNs0=";
    "aarch64-linux" = "sha256-UT+Rd6TEMYL/+xfqGxGN/tiSBvN8ntDrkCBj4PuMRwg=";
    "armv7l-linux" = "sha256-6Z+G0sLJZ3kuBHlE2uiZ2vawMVr2YYwzxXhho+6QZmQ=";
  };

  sha256 = sha256s.${system};

  src = fetchzip {
    inherit url sha256;
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    libgcc.lib
    upx
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src/$pname $out/bin/$pname
    upx -d $out/bin/$pname
  '';

  meta = with lib; {
    description = "Snell is a lean encrypted proxy protocol developed by Surge team";
    homepage = "https://kb.nssurge.com/surge-knowledge-base/release-notes/snell";
    license = licenses.unfreeRedistributable;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platformMap;
    mainProgram = pname;
  };
}
