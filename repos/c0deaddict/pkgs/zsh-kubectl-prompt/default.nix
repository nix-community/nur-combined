{ stdenv, fetchFromGitHub, zsh }:

stdenv.mkDerivation rec {
  pname = "zsh-kubectl-prompt";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "superbrothers";
    repo = pname;
    rev = "v${version}";
    sha256 = "0l467mkdqxyf9ag9nyg7j41c1vz2v3zq0piy6wdb70lhr7825rgp";
  };

  buildInputs = [ zsh ];

  installPhase = ''
    install -D kubectl.zsh \
      $out/share/zsh-kubectl-prompt/kubectl.zsh
  '';

  meta = with stdenv.lib; {
    description =
      "Display information about the kubectl current context and namespace in zsh prompt.";
    homepage = "https://github.com/superbrothers/zsh-kubectl-prompt";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
