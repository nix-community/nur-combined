{
  lib,
  stdenv,
  fetchFromGitHub,
  libtickit,
  libvterm-neovim,
}:
stdenv.mkDerivation rec {
  pname = "a4term";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "rpmohn";
    repo = "a4";
    rev = "v${version}";
    sha256 = "sha256-WuXE2R7BIZOH6bQgEagDENB/xaB2w0s9WXnm9T1pdk4=";
  };

  #
  # It seems to be the correct way to use `libvterm-neovim` instead of `libvterm`.
  #
  # See: https://discourse.nixos.org/t/how-to-compile-a-program-that-includes-vterm-h/14668
  #
  buildInputs = [libtickit libvterm-neovim];

  makeFlags = ["PREFIX=$(out)"];

  meta = with lib; {
    description = "a dynamic terminal window manager";
    homepage = "https://www.a4term.com/";
    license = licenses.mit;
    mainProgram = "a4";
  };
}
