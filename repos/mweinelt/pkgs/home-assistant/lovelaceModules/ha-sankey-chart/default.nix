{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "ha-sankey-chart";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "MindFreeze";
    repo = "ha-sankey-chart";
    rev = "refs/tags/v${version}";
    hash = "sha256-UijH98KIIjzgbjqy0QfvynKQrKxndzWE8Ve9U/izFVg=";
  };

  npmDepsHash = "sha256-N909n6wHbN0QBbVpfQfd5IlLeDZ2BQ5/bIzZm3q/ddE=";

  installPhase = ''
    mkdir $out
    cp -a dist/* $out/
  '';

  meta = with lib; {
    description = "A Home Assistant lovelace card to display a sankey chart. For example for power consumption";
    homepage = "https://github.com/MindFreeze/ha-sankey-chart";
    changelog = "https://github.com/MindFreeze/ha-sankey-chart/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
