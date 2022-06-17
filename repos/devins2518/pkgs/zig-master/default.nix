{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.2624+d506275a0";
  shas = {
    x86_64-linux =
      "591845f59fe5b9dcb56ac011aa6df12ef4730e711efa7284598141d4c4fb383f";
    aarch64-linux =
      "5ce0edb76595534e2284fe87679c2b498a7448630a716f50bd88d297d8463ac7";
    x86_64-darwin =
      "7aadf59dd866f82102573237ab4f8f601175ec1c7f6c46efb6e5cfb740308c71";
    aarch64-darwin =
      "0eef95e29a151a233832e3460f01d3a027b6b05dfcce467686d39d18003a7860";
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2022-05-23";

  src = fetchurl {
    url = "https://ziglang.org/builds/zig-${os}-${arch}-${v}.tar.xz";
    sha256 = shas.${stdenv.hostPlatform.system};
  };

  installPhase = ''
    install -D zig "$out/bin/zig"
    install -D LICENSE "$out/usr/share/licenses/zig/LICENSE"
    cp -r lib "$out/lib"
    install -d "$out/usr/share/doc"
    cp -r docs "$out/usr/share/doc/zig"
  '';

  meta = with lib; {
    description =
      "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.";
    homepage = "https://github.com/ziglang/zig";
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
