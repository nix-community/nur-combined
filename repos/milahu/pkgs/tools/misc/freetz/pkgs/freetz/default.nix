{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "freetz-ng";
  #version = "24040";
  version = "24040-unstable-2024-05-29";

  src =
  #if true then /home/user/src/freetz/freetz-ng else
  fetchFromGitHub {
    owner = "Freetz-NG";
    repo = "freetz-ng";
    #rev = "ng${version}";
    rev = "38d5e84c4579da9ddd483d2f3296bb49b9637a1a";
    hash = "sha256-uh98rGPIx5b5vl9kQntlC7ESfmw26+Ihf9Dre6mSdIg=";
  };

  buildCommand = ''
    echo dont build this package
    exit
  '';

  meta = with lib; {
    description = "Freetz-NG firmware modification for AVM devices like FRITZ!Box";
    homepage = "https://github.com/Freetz-NG/freetz-ng";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "freetz-ng";
    platforms = platforms.all;
  };
}
