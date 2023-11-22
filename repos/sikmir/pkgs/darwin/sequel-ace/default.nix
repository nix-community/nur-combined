{ lib, stdenvNoCC, fetchfromgh, unzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sequel-ace-bin";
  version = "4.0.13-20062";

  src = fetchfromgh {
    owner = "Sequel-Ace";
    repo = "Sequel-Ace";
    name = "Sequel-Ace-${lib.head (lib.splitString "-" finalAttrs.version)}.zip";
    hash = "sha256-HsMx3Xhrf6id/F9XUEVZvP9vB52d0w+Lxz+oedmSyh8=";
    version = "production/${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "MySQL/MariaDB database management for macOS";
    homepage = "https://sequel-ace.com/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
