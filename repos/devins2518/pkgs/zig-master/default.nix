{ stdenv, fetchurl, lib, v }:

let
  os = if stdenv.isLinux then "linux" else "macos";
  arch = if stdenv.isx86_64 then "x86_64" else "aarch64";
  url = {
    "0.10.0" =
      "https://ziglang.org/download/0.10.0/zig-${os}-${arch}-0.10.0.tar.xz";
    "0.11.0-dev.2624+bc804eb84" =
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
    "0.11.0-dev.2624+bc804eb84" = {
      x86_64-linux =
        "7c0e53f8d52e37c2c93f366e4d55cf44e9f0538df30bcc5b9a42d8dbd0cc3753";
      aarch64-linux =
        "e21384d7e6eac7958d7e7ed3db8a3e7330fad99d08f5232984a8637fa0cdc566";
      x86_64-darwin =
        "57a630d49a9d9429dd96f2f184c5225300950c38a4c7daddc9486285a53eac73";
      aarch64-darwin =
        "7d61211e84886177a1ad821b0498ee3379c15c9da48ebf83dbba78bcdfa1fff1";
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
