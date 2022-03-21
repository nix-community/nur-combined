{ stdenv, lib, fetchgit, librsvg, xorg, python3Packages }:

stdenv.mkDerivation rec {
  pname = "simp1e-cursors";
  version = "master";

  src = fetchgit {
    url = "https://gitlab.com/zoli111/simp1e";
    sha256 = "sha256-Nq2A8TB1o17993ozlrR5vuMj1qMeSeh3n04KaQjG1/E=";
    fetchSubmodules = true;
  };

  buildInputs = [ 
    librsvg 
    xorg.xcursorgen
    python3Packages.pillow 
  ];

  installPhase = ''
    mkdir -p $out/share/icons
    sh generate_svgs.sh && sh build_cursors.sh
    cp -r built_themes/* $out/share/icons
  '';

  meta = with lib; {
    description = "An aesthetic cursor theme for your Linux desktop";
    homepage = "https://gitlab.com/zoli111/simp1e";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
