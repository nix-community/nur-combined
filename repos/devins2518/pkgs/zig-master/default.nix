{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2021-06-27";

  src = fetchurl {
    url =
      "https://ziglang.org/builds/zig-linux-x86_64-0.9.0-dev.321+15a030ef3.tar.xz";
    sha256 = "sha256-62lvD6c+vclVVxZI7NeZ8HRutyDxvi4a1JJF17w1Qw8=";
  };

  installPhase = ''
    install -D zig "$out/usr/bin/zig"
    install -D LICENSE "$out/usr/share/licenses/zig/LICENSE"
    cp -r lib "$out/usr"
    install -d "$out/usr/share/doc"
    cp -r docs "$out/usr/share/doc/zig"
  '';

  meta = with lib; {
    description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.";
    homepage = "https://github.com/ziglang/zig";
    maintainers = with maintainers; [ devins2518 ];
    platforms = platforms.linux;
  };
}
