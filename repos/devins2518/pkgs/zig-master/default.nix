{ stdenv, fetchurl, lib, v }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  master = "0.11.0-dev.3726+8fcc28d30";
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
        "b629d0ed7591b3fb6c28c41a22c2a7cf0b4f749873026b120b7e5a7e65d2e1d7";
      aarch64-linux =
        "5ae415519ffbddbeaa9f82df58d3989d91c2c8889b56b2bc65cf5ec0d84ad3d7";
      x86_64-darwin =
        "0ed720b429ad0f1ca69618768ce2a9eab2e95f219b3e7fec39d804102a0ea1ac";
      aarch64-darwin =
        "f9e251226a6ee0f6966f3f54c846ed5eeb39df8205017288869fbfccf2ea8500";
    };
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2023-6-20";

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
