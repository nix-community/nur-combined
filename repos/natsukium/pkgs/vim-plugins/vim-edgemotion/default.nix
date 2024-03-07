{
  lib,
  buildVimPlugin,
  fetchFromGitHub,
}:
buildVimPlugin {
  pname = "vim-edgemotion";
  version = "unstable-2017-12-26";

  src = fetchFromGitHub {
    owner = "haya14busa";
    repo = "vim-edgemotion";
    rev = "8d16bd92f6203dfe44157d43be7880f34fd5c060";
    hash = "sha256-CFDU+q1CLbKgCwed5Qx728olgTpCTpYDzz6LefjEdvA=";
  };

  dontBuild = true;

  meta = with lib; {
    description = "Move to the edge!";
    homepage = "https://github.com/haya14busa/vim-edgemotion";
    license = licenses.mit;
  };
}
