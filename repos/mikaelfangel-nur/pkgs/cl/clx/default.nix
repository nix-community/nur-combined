{ lib, less, ncurses, buildGo121Module, fetchFromGitHub, makeWrapper }:

buildGo121Module rec {
  pname = "circumflex";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "bensadeh";
    repo = "circumflex";
    rev = version;
    hash = "sha256-sbyM2zBa3O0lZq3H6d0gR9m6GPZzFDiZ7QymDpRXui4=";
  };

  vendorHash = "sha256-8H8s0D/3BLq92tn1sGG/+mBZ5ULNryJfDjnj/UBI9WM=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/clx \
      --prefix PATH : ${lib.makeBinPath [ less ncurses ]}
  '';

  meta = with lib; {
    description = "A command line tool for browsing Hacker News in your terminal";
    homepage = "https://github.com/bensadeh/circumflex";
    license = licenses.agpl3;
    mainProgram = "clx";
  };
}
