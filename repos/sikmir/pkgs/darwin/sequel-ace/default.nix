{ lib, stdenvNoCC, fetchfromgh, unzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sequel-ace-bin";
  version = "4.0.7";

  src = fetchfromgh {
    owner = "Sequel-Ace";
    repo = "Sequel-Ace";
    name = "Sequel-Ace-${finalAttrs.version}.zip";
    hash = "sha256-yTaj2HvhGwGKB/YqaBkYWD3B9gpn/KS+joTxo0ytBiM=";
    version = "production/${finalAttrs.version}-20050";
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
