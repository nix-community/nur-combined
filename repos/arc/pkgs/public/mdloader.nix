{ stdenv, fetchFromGitHub }: stdenv.mkDerivation rec {
  name = "mdloader";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Massdrop";
    repo = "mdloader";
    rev = version;
    sha256 = "1d2z0wcc6xi8gc5hggrms6wcdc4jgdc46q6q9am282i2llpscazd";
  };

  installPhase = ''
    install -Dm0755 -t $out/bin build/mdloader
  '';
}
