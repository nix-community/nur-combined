{ lib
, buildVimPlugin
, fetchFromGitHub
, nix-gitignore
}:

buildVimPlugin {
  pname = "decisive-vim";
  version = "2024-06-15";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "decisive.nvim";
    rev = "97cda9352039cbdcc2f3f0716eb2d3aa4929048a";
    sha256 = "sha256-po5PZJvEphHoFWpLNlO6p812KPv5AjaBA0UpiDPvo6g=";
  };
  # src = nix-gitignore.gitignoreSource [ ] /home/scott/GIT/decisive.nvim;

  meta = with lib; {
    description = "Neovim plugin to assist work with CSV files";
    license = licenses.mit;
    homepage = "https://github.com/emmanueltouzery/decisive.nvim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
