{ stdenv, fetchurl, lib, v }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  url = {
    "0.10.0" =
      "https://ziglang.org/download/0.10.0/zig-${os}-${arch}-0.10.0.tar.xz";
    "0.11.0-dev.1023+1c711b0a6" =
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
    "0.11.0-dev.1023+1c711b0a6" = {
      x86_64-linux =
        "ad7877a741719797ca094f8111da056fc8e4324d6f7d91248c8c1f6a9f4b8684";
      aarch64-linux =
        "69ab0323c8bb37d64aa40503ffb78c055785af0ed70e1bfda133b75e6ef72c6f";
      x86_64-darwin =
        "286ae9577b3575e019ed6db34d899cd56d272c5cdb142b0eabfc83ae446ffc46";
      aarch64-darwin =
        "a1663549fc7c716955407741dedb0d2caaaf8d647f8d5b3c6cf42ef7acf686b6";
    };
  };
in stdenv.mkDerivation rec {
  pname = "zig-master";
  version = "unstable-2023-1-1";

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
