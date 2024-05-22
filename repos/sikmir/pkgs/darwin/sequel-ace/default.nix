{
  lib,
  stdenvNoCC,
  fetchfromgh,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sequel-ace";
  version = "4.0.17-20067";

  src = fetchfromgh {
    owner = "Sequel-Ace";
    repo = "Sequel-Ace";
    name = "Sequel-Ace-${lib.head (lib.splitString "-" finalAttrs.version)}.zip";
    hash = "sha256-I1wVmamN9x9il+9XeJxmrsSyG3Y27+3/Jt4Q9P6Q7dI=";
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
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
