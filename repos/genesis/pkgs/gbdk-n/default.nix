{ stdenv, fetchFromGitHub, automake, sdcc }:

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "gbdk-n";
  version = "unstable-2019-19-09";

  src = fetchFromGitHub {
    owner = "andreasjhkarlsson";
    repo = "gbdk-n";
    rev = "2592ba475a06ea92a27b3d072c4a1e919187d8bf";
    sha256 = "0w25gh8mddz6wmhbdih4bjai0j85kark7hfz16wk64d8jm12mr46";
  };

  nativeBuildInputs = [ automake ];
  buildInputs = [ sdcc ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib,obj,include}
    cp bin/*.sh $out/bin
    cp lib/* $out/lib
    cp obj/* $out/obj
    cp -r include/* $out/include

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    make examples
  '';

  meta = {
    description = "GBDK is an SDK for gameboy platform";
    longDescription = ''
      The Gameboy Development Kit (GBDK) is an SDK for developing applications/games for the gameboy platform.
    '';
    homepage = "https://github.com/andreasjhkarlsson/gbdk-n";
    license = "unknown";
    maintainers = with maintainers; [ genesis ];
    platforms = platforms.linux;
  };
}
