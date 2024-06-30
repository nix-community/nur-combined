{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dvorak";
  version = "4c100fb";
  src = fetchFromGitHub {
    owner = "tbocek";
    repo = "dvorak";
    rev = "${version}";
    sha256 = "sha256-UwFrQK/yBveO9OY+zYiLa7ZpcFWnxnvu47N/+X49oHc=";
  };

  buildInputs = [ ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp dvorak $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/tbocek/dvorak";
    description = "Dvorak <> Qwerty - Keyboard remapping for Linux when pressing L-CTRL, L-ALT, or L-WIN";
    license = licenses.asl20;
    maintainers = with maintainers; [ suhr ];
  };
}
