{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.11.0-dev.174+d823680e1";
  shas = {
    x86_64-linux =
      "9d0e4724c7bc999f0445af1e5e2e10b69989344e3f8ee126fbbe57397a6f66aa";
    aarch64-linux =
      "c1544a01bd0faf8cd5508329a71cfa35d4ba56c741929529c46bc351deaa9905";
    x86_64-darwin =
      "d3aea33d16f7105dfe3cf4c48d02a938a6f750e099767879b8ee19bd51b7aa39";
    aarch64-darwin =
      "c8d712ac0078f160479f7bc46b1f5afa7f9cadb736a4b865058da1605c57bb26";
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2022-11-14";

  src = fetchurl {
    url = "https://ziglang.org/builds/zig-${os}-${arch}-${v}.tar.xz";
    sha256 = shas.${stdenv.hostPlatform.system};
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
