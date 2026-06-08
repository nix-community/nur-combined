{ lib
, buildPythonApplication
, fetchFromGitHub
, poetry-core
, hy
, hyrule
, toolz
, pygls
, setuptools
, ...
}:

buildPythonApplication rec {
  pname = "hyuga";
  version = "1.0.0-unstable-2025-01-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sakuraiyuta";
    repo = "hyuga";
    rev = "c8a7cb5cbbde31c81d1734b6e6d21f5371da61b5";
    hash = "sha256-s1ysZ9UudCvQed9CxpAKxDtjAWqBkSjj8Qr5Uae1/0I=";
  };

  # Two patches:
  # - vendor-walk: hyrule 1.0 dropped `walk` from hyrule.collections; vendor it.
  # - pygls-2: pygls 2.0 moved LanguageServer to pygls.lsp.server; apply only on >= 2.0.
  patches = [ ./vendor-walk.patch ]
    ++ lib.optionals (lib.versionAtLeast pygls.version "2.0.0") [ ./pygls-2.patch ];

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    hy
    hyrule
    toolz
    pygls
    setuptools
  ];

  # Upstream poetry caps (hyrule<0.8, toolz<0.13, setuptools<76) lag behind
  # nixpkgs; the newer versions are compatible (hyrule via the vendor patch).
  pythonRelaxDeps = [
    "hyrule"
    "toolz"
    "setuptools"
  ];

  pythonImportsCheck = [ "hyuga" ];

  meta = with lib; {
    description = "Hyuga - Yet Another Hy Language Server";
    homepage = "https://github.com/sakuraiyuta/hyuga";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "hyuga";
  };
}
