{ stdenv, fetchurl, lib }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  v = "0.10.0-dev.2351+b64a1d5ab";
  shas = {
    x86_64-linux =
      "98646dc6886a6acc88c571258c1984b0bac3e7e6e7ca13ee8563b22d4fb67998";
    aarch64-linux =
      "69f437de06b88c0b24040b162374aa685b955d9446ae9b3bc8b6a6f161fe3435";
    x86_64-darwin =
      "8fc0901479b8f39a54ea83d9634e5d0a1970f92d82fd862447f80fe6893c06ba";
    aarch64-darwin =
      "3f1b50e4eb06fb25e7c60aabe9fedae49f5d04dca23420badfadee5d7629cb7f";
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
