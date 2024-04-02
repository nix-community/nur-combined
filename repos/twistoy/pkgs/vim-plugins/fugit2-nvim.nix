{
  buildVimPlugin,
  fetchFromGitHub,
  libgit2,
  ...
}: let
  version = "d78ad4654346115ca3a555d5286f53d4c1094dfd";
  fugit2-nvim-src = fetchFromGitHub {
    owner = "SuperBo";
    repo = "fugit2.nvim";
    rev = version;
    sha256 = "Wmj8EaHcOfN4AV/3XrP958FtDstxQyhRyGIYs+MfcS0=";
  };
in
  buildVimPlugin {
    pname = "fugit2-nvim";
    inherit version;
    src = fugit2-nvim-src;
    buildInputs = [libgit2];
    postFixup = ''
      substituteInPlace $out/lua/fugit2/libgit2.lua \
        --replace 'ffi.load "libgit2"' 'ffi.load "${libgit2}/lib/libgit2.so"'
    '';
    meta = {
      homepage = "https://github.com/SuperBo/fugit2.nvim";
      description = "A porcelain git helper inside Neovim powered by libgit2";
    };
  }
