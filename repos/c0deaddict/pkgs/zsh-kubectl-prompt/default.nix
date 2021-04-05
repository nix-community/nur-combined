{ lib, stdenv, fetchFromGitHub, zsh }:

stdenv.mkDerivation rec {
  pname = "zsh-kubectl-prompt";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "superbrothers";
    repo = pname;
    rev = "v${version}";
    sha256 = "10gmhxcg2qvb6lcsckrmrgza6pr5gf79vwp96822casqrhc15q3q";
  };

  buildInputs = [ zsh ];

  installPhase = ''
    install -D kubectl.zsh \
      $out/share/zsh-kubectl-prompt/kubectl.zsh
  '';

  meta = with lib; {
    description =
      "Display information about the kubectl current context and namespace in zsh prompt.";
    homepage = "https://github.com/superbrothers/zsh-kubectl-prompt";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
