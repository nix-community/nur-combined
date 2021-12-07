{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "your-editor";
  version = "1301";

  src = fetchFromGitHub {
    owner = "your-editor";
    repo = "yed";
    rev = "cfcefaf5d77342a04c011cb9ac81e6f23bc453a6";
    sha256 = "6p++3UasMBAQAMD/P5UrIOpqqwZPcxWkCQx5Nqgbgk8=";
  };

  installPhase = ''
    runHook preInstall
    patchShebangs install.sh
    ./install.sh -p $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Your-editor (yed) is a small and simple terminal editor core that is meant to be extended through a powerful plugin architecture";
    homepage = "https://your-editor.org/";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ uniquepointer ];
    mainProgram = "yed";
  };
}
