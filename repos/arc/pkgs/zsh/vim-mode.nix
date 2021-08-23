{ buildZshPlugin, lib, fetchFromGitHub }:

buildZshPlugin rec {
  pname = "zsh-vim-mode";
  version = "2021-03-21";

  src = fetchFromGitHub {
    owner = "softmoth";
    repo = pname;
    rev = "1f9953b7d6f2f0a8d2cb8e8977baa48278a31eab";
    sha256 = "1i79rrv22mxpk3i9i1b9ykpx8b4w93z2avck893wvmaqqic89vkb";
  };

  meta = with lib; {
    homepage = "https://github.com/softmoth/zsh-vim-mode";
    description = "Friendly bindings for ZSH's vi mode";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
