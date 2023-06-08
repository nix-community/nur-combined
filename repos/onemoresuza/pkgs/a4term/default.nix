{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  libtickit,
  libvterm-neovim,
}:
stdenv.mkDerivation rec {
  pname = "a4term";
  version = "v0.2.1";

  src = fetchFromGitHub {
    owner = "rpmohn";
    repo = "a4";
    rev = version;
    sha256 = "sha256-WuXE2R7BIZOH6bQgEagDENB/xaB2w0s9WXnm9T1pdk4=";
  };

  #
  # TODO: Find out why using `libvterm` throws an error, while `libvterm-neovim` does not.
  #
  buildInputs = [libtickit libvterm-neovim];

  makeFlags = ["PREFIX=$(out)"];

  meta = with lib; {
    description = ''
      a dynamic terminal window manager
    '';
    homepage = "https://www.a4term.com/";
    license = licenses.mit;
  };
}
