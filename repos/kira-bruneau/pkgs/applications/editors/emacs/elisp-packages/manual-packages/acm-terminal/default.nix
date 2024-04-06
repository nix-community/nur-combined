{ lib
, melpaBuild
, fetchFromGitHub
, acm
, popon
, writeText
, unstableGitUpdater
}:

let
  rev = "1851d8fa2a27d3fd8deeeb29cd21c3002b8351ba";
in
melpaBuild {
  pname = "acm-terminal";
  version = "unstable-2023-12-06"; # 13:26 UTC

  src = fetchFromGitHub {
    owner = "twlz0ne";
    repo = "acm-terminal";
    inherit rev;
    sha256 = "sha256-EYhFrOo0j0JSNTdcZCbyM0iLxaymUXi1u6jZy8lTOaY=";
  };

  commit = rev;

  packageRequires = [
    acm
    popon
  ];

  recipe = writeText "recipe" ''
    (acm-terminal :repo "twlz0ne/acm-terminal" :fetcher github)
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Patch for LSP bridge acm on Terminal";
    homepage = "https://github.com/twlz0ne/acm-terminal";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
