{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.2820+48fd92365";
  shas = {
    x86_64-linux =
      "c8866074cef8f94d5dc1dda724fc61e6d334c83a9a22ca513cd064fa2a90262f";
    aarch64-linux =
      "64f59863499102219688f81805a0158ecfb73d42f8a22862912aff9eb2cb75c1";
    x86_64-darwin =
      "6ca9c7ead5aec68db5c472f1a9342875b35463e853b3acfbc4f9e9a4298993ae";
    aarch64-darwin =
      "09e70ca32c0b6a1f35b8674c4dc1cc2a3291335abb9fd97703e1d32c3c97b6d7";
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
