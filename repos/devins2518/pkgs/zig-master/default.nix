{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2021-06-27";

  src = fetchurl {
    url =
      "https://ziglang.org/builds/zig-linux-x86_64-0.9.0-dev.1175+1f2f9f05c.tar.xz";
    sha256 = "sha256-cHoXBWMYS3+XpoXyQ5VDbgypwilDmPAx2Pi8Z5eEhUo=";
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
    platforms = platforms.linux;
  };
}
