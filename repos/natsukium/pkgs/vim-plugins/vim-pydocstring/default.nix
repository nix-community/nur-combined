{
  lib,
  buildVimPlugin,
  fetchFromGitHub,
  doq,
}:
buildVimPlugin rec {
  pname = "vim-pydocstring";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "heavenshell";
    repo = "vim-pydocstring";
    rev = "refs/tags/${version}";
    hash = "sha256-z8mIRjXfkM/r21FoLuIUaMkHiDs6kjjtNcztMijKl4E=";
  };

  buildInputs = [doq];
  postPatch = ''
    substituteInPlace autoload/pydocstring.vim \
      --replace "printf('%s/lib/doq', expand('<sfile>:p:h:h'))" "'${doq}/bin/doq'"
  '';
  dontBuild = true;

  meta = with lib; {
    description = "Generate Python docstring to your Python source code";
    homepage = "https://github.com/heavenshell/vim-pydocstring";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
