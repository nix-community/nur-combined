{ lib
, python3
, fetchFromGitHub
, tree-sitter-grammars
}:

python3.pkgs.buildPythonPackage rec {
  pname = "tree-sitter-languages";
  version = "1.10.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "grantjenks";
    repo = "py-tree-sitter-languages";
    rev = "v${version}";
    hash = "sha256-AuPK15xtLiQx6N2OATVJFecsL8k3pOagrWu1GascbwM=";
  };

  patches = [
    # this has 2 benefits:
    # 1. this package builds 1000x faster
    # 2. no more symbol conflicts between parsers
    #    https://github.com/grantjenks/py-tree-sitter-languages/issues/55
    ./use-prebuilt-grammars.patch
  ];

  buildInputs = [
    python3.pkgs.cython
  ];

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.tree-sitter
  ];

  postBuild = ''
    languages=$out/${python3.sitePackages}/tree_sitter_languages/languages
    echo creating $languages
    mkdir -p $languages
    ${
      builtins.concatStringsSep "" (
        builtins.attrValues (
          builtins.mapAttrs
          (_n: p:
            # 12 == builtins.stringLength "tree-sitter-"
            let n = builtins.substring 12 999 _n; in
            ''
              echo adding language ${n}
              ln -s ${p.outPath}/parser $languages/${n}
            ''
          )
          (lib.filterAttrs (k: v: v ? outPath) tree-sitter-grammars)
        )
      )
    }
  '';

  pythonImportsCheck = [ "tree_sitter_languages" ];

  meta = with lib; {
    description = "Python module with all tree-sitter languages";
    homepage = "https://github.com/grantjenks/py-tree-sitter-languages";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
