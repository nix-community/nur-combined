{
  stdenv,
  fetchurl,
  lib,
}:

let
  version = "1.0.5";
  pname = "yunyi-cli";
  platforms = {
    "x86_64-linux" = {
      pkg = "yunyi-cli-linux-amd64";
      arch = "amd64";
    };
    "aarch64-darwin" = {
      pkg = "yunyi-cli-darwin-arm64";
      arch = "arm64";
    };
  };
  platform = platforms.${stdenv.hostPlatform.system} or null;
in

assert platform != null;

stdenv.mkDerivation rec {
  inherit pname version;
  src = fetchurl {
    url = "https://registry.npmjs.org/${platform.pkg}/-/${platform.pkg}-${version}.tgz";
    hash =
      {
        "x86_64-linux" = "sha256-IO3LKnPnAKxs5A7/yQ7sGAnz0R9yOVs0RAPykAAzRKo=";
        "aarch64-darwin" = "sha256-ScH8TKhEvmcdiWys/f09G8ip7e2xYduPRwxxilRYCiA=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar --strip-components=2 -xzf $src "package/bin/${platform.pkg}"
    mv "${platform.pkg}" $out/bin/yunyi-cli
    chmod +x $out/bin/yunyi-cli
  '';
  meta = with lib; {
    description = "yunyi-cli packaged from npmjs for ${stdenv.hostPlatform.system}";
    platforms = [ stdenv.hostPlatform.system ];
    license = licenses.unfree;
    mainProgram = "yunyi-cli";
  };
}
