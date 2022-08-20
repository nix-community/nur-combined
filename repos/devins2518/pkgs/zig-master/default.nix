{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.3659+e5e6eb983";
  shas = {
    x86_64-linux =
      "7358576b8f4e503c04884ad7d399231674519fb12e09d97e3bec64ad76bca0e2";
    aarch64-linux =
      "ae2b6df070eaf4c6d0062cccf27206cd716aa9e12f45e14818b3451494998e34";
    x86_64-darwin =
      "a5e6d500dcb3c771eca30b639d53ec05bcd07880ba049b8a3de28e8810f17646";
    aarch64-darwin =
      "d230f5871e21e70df2ae1028978eb23d1684a866ce4dd418608e3327fd40efdd";
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2022-08-10";

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
