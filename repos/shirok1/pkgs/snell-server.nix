{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  libgcc,
}:

let
  system = stdenv.hostPlatform.system;

  platformMap = {
    "x86_64-linux" = "linux-amd64";
    "i686-linux" = "linux-i386";
    "aarch64-linux" = "linux-aarch64";
  };

  # to get the hash, open nix repl
  # pkgs = import <nixpkgs> {}
  # builtins.readDir (pkgs.fetchzip { url = "https://dl.nssurge.com/snell/snell-server-v${version}-${platform}.zip"; })
  hashes = {
    "x86_64-linux" = "sha256-fcmYo1wkcXIpQ3/kArovYOpbs4qwibs5nyPpY/0pwHs=";
    "i686-linux" = "sha256-uWJsWogdKZRH/EWVMe9pRgouzSB3J4yXuNXn4pyizVE=";
    "aarch64-linux" = "sha256-PLQLxVNw23YMbFQYf6QKO2hRtyluZOEa9FP9KgILgns=";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "snell-server";
  version = "6.0.0rc";

  src = fetchzip {
    url = "https://dl.nssurge.com/snell/snell-server-v${finalAttrs.version}-${platformMap.${system}}.zip";
    hash = hashes.${system};
  };

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
    mainProgram = "snell-server";
  };
})
