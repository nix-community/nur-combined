{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  version = "49068ec-master";
  name = "dokuwiki-plugin-todo-${version}";
  src = fetchFromGitHub {
    owner = "leibler";
    repo = "dokuwiki-plugin-todo";
    rev = "49068ecea455ea997d1e4a7adab171ccaf8228e8";
    sha256 = "1jaq623kp14fyhamsas5mk9ryqlk4q6x6znijrb5xhcdg3r83gmq";
  };
  installPhase = ''
    mkdir $out
    cp -a * $out
    '';
  passthru = {
    pluginName = "todo";
  };
}
