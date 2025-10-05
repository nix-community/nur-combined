{
  lib,
  stdenvNoCC,
  fetchfromgh,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sequel-ace";
  version = "4.1.7-20080";

  src = fetchfromgh {
    owner = "Sequel-Ace";
    repo = "Sequel-Ace";
    tag = "production/${finalAttrs.version}";
    hash = "sha256-tJh3fLPrHhh1CKTN1iAGQnhqeCoZ5hN5ytL0KwplgHk=";
    name = "Sequel-Ace-${lib.head (lib.splitString "-" finalAttrs.version)}.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = {
    description = "MySQL/MariaDB database management for macOS";
    homepage = "https://sequel-ace.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
