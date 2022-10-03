{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.4217+9d8cdb855";
  shas = {
    x86_64-linux =
      "795daa1bed55b10a5fb22de8e8e5eb58bfbcb445bcbf9ffbc2150bd01b6dbe1b";
    aarch64-linux =
      "c1544a01bd0faf8cd5508329a71cfa35d4ba56c741929529c46bc351deaa9905";
    x86_64-darwin =
      "64dee888be7d71b6516557bb8cd3d71a373684c6fc2ae3444954dc01512f48cb";
    aarch64-darwin =
      "0675d47dff0ad23d43f43b672caab5c1e37043c8ac1b2fbad542b1d425159940";
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
