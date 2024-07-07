{ lib
, buildVimPlugin
, fetchFromGitHub
, coreutils
}:

buildVimPlugin {
  pname = "vim-async";
  version = "2022-04-04";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "async.vim";
    rev = "2082d13bb195f3203d41a308b89417426a7deca1";
    sha256 = "sha256-YxZdOpV66YxNBACZRPugpk09+h42Sx/kjjDYPnOmqyI=";
  };

  meta = with lib; {
    description = "Normalize async job control api for vim and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/async.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
