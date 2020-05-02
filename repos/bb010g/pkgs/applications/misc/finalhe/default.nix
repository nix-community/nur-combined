{ stdenv, buildPackages, fetchFromGitHub
, libiconv, libusb1, libxml2
}:

let
  inherit (stdenv.lib) chooseDevOutputs;
in stdenv.mkDerivation rec {
  pname = "finalhe";
  version = "1.81.0";

  src = fetchFromGitHub {
    owner = "soarqin";
    repo = "finalhe";
    # rev = "v${version}";
    rev = "v1.81";
    sha256 = "0cl7nk0rlfbzcvd3dd8wc33769nmiiqxzfi5dd5r0cn4xb6j91n9";
  };

  nativeBuildInputs = [
    buildPackages.pkgconfig
    buildPackages.qmake
    buildPackages.qttools
  ];
  buildInputs = chooseDevOutputs [
    libiconv
    libusb1
    libxml2
  ];

  preConfigure = ''
    lrelease src/translations/*.ts
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "''${!outputBin}/bin"
    cp -t "''${!outputBin}/bin" src/FinalHE

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description =
      "Tool to push h-encore exploit for PS VITA/PS TV automatically";
    homepage = "https://github.com/soarqin/finalhe";
    downloadPage = "https://github.com/soarqin/finalhe/releases";
    license = with licenses; gpl3Plus;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
