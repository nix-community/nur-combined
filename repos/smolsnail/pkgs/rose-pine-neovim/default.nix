{ buildVimPlugin, fetchFromGitHub, lib }:

buildVimPlugin rec {
  pname = "rose-pine-neovim";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "neovim";
    rev = "v${version}";
    sha256 = "08h2f6bq1l21mgsn2sid978mhbxv2j9jhzqyf0n3hg9y6mi94c9x";
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
