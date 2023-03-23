{
  lib,
  pkgs,
  buildVimPlugin,
  fetchFromGitHub,
}: let
  doq = pkgs.python3Packages.callPackage ../../doq { };
  prev = ''
    let g:pydocstring_doq_path = get(
      \ g:,
      \ 'pydocstring_doq_path',
      \ printf('%s/lib/doq', expand('<sfile>:p:h:h'))
      \ )'';
in
  buildVimPlugin {
    name = "vim-pydocstring";
    src = fetchFromGitHub {
      owner = "heavenshell";
      repo = "vim-pydocstring";
      rev = "2.5.0";
      hash = "sha256-z8mIRjXfkM/r21FoLuIUaMkHiDs6kjjtNcztMijKl4E=";
    };

    buildInputs = [doq];
    postPatch = ''
      substituteInPlace autoload/pydocstring.vim --replace "${prev}" \
        "let g:pydocstring_doq_path = get(g:, 'pydocstring_doq_path', '${doq}/bin/doq')"
    '';
    dontBuild = true;

    meta = with lib; {
      description = "Generate Python docstring to your Python source code";
      homepage = "https://github.com/heavenshell/vim-pydocstring";
      license = licenses.bsd3;
      platforms = platforms.unix;
    };
  }
