{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.980+db82c1b98";
  shas = {
    x86_64-linux =
      "abe01c5c322c1a1a9b4280a280cf58ed6f2dc688875eed98956746c9e026de14";
    aarch64-linux =
      "6555ba1ba1d5177ac6e4494ad57c64cd7d39eb6567e6524813de3fab58451250";
    x86_64-darwin =
      "33c27030e17f96e0619d15b603bc23b4ae73b8106434c93066d0cb72ba764c74";
    aarch64-darwin =
      "97e5bef1c54b9a3697d13794568d9bba22d401a414382688608711d57059e478";
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2022-02-26";

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
