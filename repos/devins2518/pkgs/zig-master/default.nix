{ stdenv, fetchurl, lib, v }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  url = {
    "0.10.0" =
      "https://ziglang.org/download/0.10.0/zig-${os}-${arch}-0.10.0.tar.xz";
    "0.11.0-dev.740+4d2372139" =
      "https://ziglang.org/builds/zig-${os}-${arch}-${v}.tar.xz";
    "0.11.0-dev.939+5bde627f9" =
      "https://ziglang.org/builds/zig-${os}-${arch}-${v}.tar.xz";
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
    "0.11.0-dev.740+4d2372139" = {
      x86_64-linux =
        "bd83ec901811539918d7336303a5b6e02440f8a3e9ca20eec51188aaa50155e1";
      aarch64-linux =
        "72e8f2014cb4b7b8ab970fc292cb759f58426a118de4ab10c1b8a8ee1979a79b";
      x86_64-darwin =
        "8ba0fb335f8e013c6a939596b5f5f43ce451668e38079c50ba58bf4465116a91";
      aarch64-darwin =
        "0ad66fdf578ae2a8f54025c69d1f92a0f2fa661f99cb983a9dbe10cc5a6c85bc";
    };
    "0.11.0-dev.939+5bde627f9" = {
      x86_64-linux =
        "21b38830cc9eb44942c01a3a1c445191e46a95e94a8c6d0f7221336ef8aec9f4";
      aarch64-linux =
        "6815fab7b9c2bc5f1c5cdbf1122e2a99d5ac6b1d176218a458f028d6fb06c329";
      x86_64-darwin =
        "4f547fdf313f62eb06f36597ef5a718ad57383c85cb15880449285c9fa86ee34";
      aarch64-darwin =
        "00ef253060c141e8c73863eed584dc7cc10c3202b5df0102b1e9b66665dcaada";
    };
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2022-12-24";

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
