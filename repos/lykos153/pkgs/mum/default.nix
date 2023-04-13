{ pkgs, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "mum";
  # renovate: datasource=github-releases depName=mum-rs/mum
  version = "0.5.1";
  src = fetchFromGitHub {
    owner = "mum-rs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-r2isuwXq79dOQQWB+CsofYCLQYu9VKm7kzoxw103YV4=";
  };
  cargoSha256 = "sha256-2BYU5hZE9OULuKz12CzWqpRiWbU3De9PuBrjoLRvTlM=";

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
  ];

  buildInputs = with pkgs; [
    openssl
    glib
    gdk-pixbuf
    alsa-lib
    libnotify
    libopus
  ];

  meta = with lib; {
    description = "Daemon/cli mumble client";
    homepage = "https://github.com/mum-rs/mum";
    license = licenses.mit;
  };
}
