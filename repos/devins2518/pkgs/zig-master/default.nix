{ stdenv, fetchurl, lib, v, coreutils }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  master = "0.11.0-dev.4002+7dd1cf26f";
  url = {
    "0.10.0" =
      "https://ziglang.org/download/0.10.0/zig-${os}-${arch}-0.10.0.tar.xz";
    ${master} = "https://ziglang.org/builds/zig-${os}-${arch}-${v}.tar.xz";
  };
  shas = {
    "0.10.0" = {
      x86_64-linux =
        "631ec7bcb649cd6795abe40df044d2473b59b44e10be689c15632a0458ddea55";
      aarch64-linux =
        "09ef50c8be73380799804169197820ee78760723b0430fa823f56ed42b06ea0f";
      x86_64-darwin =
        "3a22cb6c4749884156a94ea9b60f3a28cf4e098a69f08c18fbca81c733ebfeda";
      aarch64-darwin =
        "02f7a7839b6a1e127eeae22ea72c87603fb7298c58bc35822a951479d53c7557";
    };
    ${master} = {
      x86_64-linux =
        "b1ed8e3ce2fb277efdfac2330601467d63e67782e8f6cf467977adf738d9c92a";
      aarch64-linux =
        "89c22c85df280cd101358aff913aa15581ea0bc1b52d50cfe67a83dfab43a45d";
      x86_64-darwin =
        "4f00a0a12145f30aa3f5c0430722d4fcb753d2e051064fbbd0b1b0e17981ef33";
      aarch64-darwin =
        "26e615194f930c64dbf3b02ca01cf2c6f07e8ac1c274c2905af3790c7e344e8b";
    };
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2023-7-15";

  src = fetchurl {
    url = url.${v};
    sha256 = shas.${v}.${stdenv.hostPlatform.system};
  };

  installPhase = ''
    install -D zig "$out/bin/zig"
    install -D LICENSE "$out/usr/share/licenses/zig/LICENSE"
    cp -r lib "$out/lib"
    install -d "$out/usr/share/doc"
    cp -r doc "$out/usr/share/doc/zig"
  '';

  meta = with lib; {
    description =
      "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.";
    homepage = "https://github.com/ziglang/zig";
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
