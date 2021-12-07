{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "your-editor";
  version = "1301";

  src = fetchFromGitHub {
    owner = "kammerdienerb";
    repo = "yed";
    rev = "9a02eda459376563450942a8fc00b898471ce75a";
    sha256 = "e7d1ltLvU99zamleCWG9UZJ5hIFJoMlkuJSjA0n5GQM=";
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
