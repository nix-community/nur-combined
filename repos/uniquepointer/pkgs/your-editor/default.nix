{ lib, stdenv, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "your-editor";
  version = "1303";

  src = fetchFromGitHub {
    owner = "your-editor";
    repo = "yed";
    rev = "1b044e5704fcf8de142ae1d5a6eb45728f0d91a2";
    sha256 = "BWy/icQs8hVtNeM/mCi6LOah1UG0elU/DgCmfaIPD64=";
  };

  buildInput = [ pkgs.git pkgs.gcc ];
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
    platforms = platforms.unix;
    maintainers = with maintainers; [ uniquepointer ];
    mainProgram = "yed";
  };
}
