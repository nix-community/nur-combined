{ lib, stdenvNoCC, fetchFromGitHub
, zsh
}:

stdenvNoCC.mkDerivation rec {
  pname = "zsh-capture-completion";
  version = "740fce754393513d57408bc585fde14e4404ba5a";

  src = fetchFromGitHub {
    owner = "Valodim";
    repo = "zsh-capture-completion";
    rev = version;
    sha256 = "sha256-ZfIYwSX5lW/sh0dU13BUXR4nh4m9ozsIgC5oNl8LaBw=";
  };

  buildInputs = [ zsh ];

  installPhase = ''
    install -D -t $out/bin capture.zsh
    install -D -t $out/share/zsh-capture-completion readme.md LICENSE
  '';

  meta = with lib; {
    description = "Non-interactively use the zsh autocompletion system";
    homepage = "https://github.com/Valodim/zsh-capture-completion";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.bendlas ];
  };
}
