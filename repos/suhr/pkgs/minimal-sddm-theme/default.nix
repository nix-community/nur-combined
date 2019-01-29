{ stdenv, fetchurl, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "minimal-sddm-theme-${version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "egdoc";
    repo = "minimal-sddm-theme";
    rev = "504a9eed78118d09c67c93d3c9af712c3e292864";
    sha256 = "0d8lyhl1znkkqznv075j7xj32hvhjx2d83yv4409yxdn0i2apbk8";
  };

  buildInputs = [
  ];

  nativeBuildInputs = [
  ];

  installPhase = ''
    rm minimal.png
    mkdir -p $out/share/sddm/themes/minimal-sddm-theme
    mv * $out/share/sddm/themes/minimal-sddm-theme
  '';

  meta = with stdenv.lib; {
    description = "Minimal theme for sddm display manager";
    homepage = https://github.com/egdoc/minimal-sddm-theme;
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
