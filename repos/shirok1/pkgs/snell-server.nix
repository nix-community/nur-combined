{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  libgcc,
}:

let
  pname = "snell-server";
  version = "6.0.0b4";

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
  hashes = {
    "x86_64-linux" = "sha256-EHtJUmFmYYSJPc4D0DOaNEhvAQL2nJHzjuAIUtlRkos=";
    "i686-linux" = "sha256-/G5rqvWGp+gg3M7EFkaVzwpgJnApFRIrb3+QSmnA5es=";
    "aarch64-linux" = "sha256-C+W69jh08mSjRKWsN3Og+sl3iTnFs02+IjlGr6ByuKs=";
  };

  src = fetchzip {
    inherit url;
    hash = hashes.${system};
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    libgcc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 $src/$pname $out/bin/$pname

    runHook postInstall
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
