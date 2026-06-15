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
  version = "6.0.0b2";

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "i686-linux" = "linux-i386";
    "aarch64-linux" = "linux-aarch64";
  };

  system = stdenv.hostPlatform.system;

  platform = platformMap.${system} or (throw "Unsupported platform: ${system}");

  url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip";

  # to get the hash, open nix repl
  # pkgs = import <nixpkgs> {}
  # builtins.readDir (pkgs.fetchzip { url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip"; })
  sha256s = {
    "x86_64-linux" = "sha256-nNAxiQEqEIQGiRI5VWQkmZXwfYvAHD0eWwxTMzVQ+QY=";
    "i686-linux" = "sha256-xTQOFTjsxA0XEWccyzUFlnA1e5sPrnB1w5RX/dfSAr0=";
    "aarch64-linux" = "sha256-jWprkM4u3u4GLb+ftmutDfynmBzSRTagEQ48EEvYo04=";
  };

  sha256 = sha256s.${system};

  src = fetchzip {
    inherit url sha256;
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    upx
  ];
  buildInputs = [
    libgcc.lib
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
