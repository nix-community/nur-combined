{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix {

  pname = "vim-async";
  version = "2020-06-27";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "async.vim";
    rev = "0fb846e1eb3c2bf04d52a57f41088afb3395212e";
    sha256 = "1glzg0i53wkm383y1vbddbyp1ivlsx2hivjchiw60sr9gccn8f8l";
  };

  meta = with lib; {
    description = "Normalize async job control api for vim and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/async.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
