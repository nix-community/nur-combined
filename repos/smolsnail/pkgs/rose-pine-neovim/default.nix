{ buildVimPlugin, fetchFromGitHub, lib }:

buildVimPlugin rec {
  pname = "rose-pine-neovim";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "neovim";
    rev = "v${version}";
    sha256 = "1j0xxrva639xvxm9r6n1c3mnks6aw82r1w395sc20hnc76snxf9q";
  };
  meta = with lib; {
    description = "Soho vibes for Neovim";
    longDescription = ''
      Rosé Pine for Neovim.
      All natural pine, faux fur and a bit of soho vibes for the classy minimalist.
    '';
    homepage = "https://github.com/rose-pine/neovim";
    license = licenses.free;
    platforms = platforms.all;
  };
}
