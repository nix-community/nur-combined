{
  stdenv,
  lib,
  fetchurl,
  jre_minimal,
  version ? "1.6",
  ...
}:
let
  jre = jre_minimal.override {
    modules = [
      "java.prefs"
      "java.desktop"
    ];
  };

  links = {
    "1.5" = {
      url = "https://github.com/TheThirdOne/rars/releases/download/v1.5/rars1_5.jar";
      sha256 = "sha256-w75gfARfR46Up6qng1GYL0u8ENfpD3xHhl/yp9lEcUE=";
    };
    "1.6" = {
      url = "https://github.com/TheThirdOne/rars/releases/download/v1.6/rars1_6.jar";
      sha256 = "sha256-eA9zDrRXsbpgnpaKzMLIt32PksPZ2/MMx/2zz7FOjCQ=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "rars";
  src = fetchurl {
    url = links.${version}.url;
    sha256 = links.${version}.sha256;
  };

  buildInputs = [ jre ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/rars.jar
    cat > $out/bin/rars <<EOF
    #!${stdenv.shell}
    exec ${jre}/bin/java -jar $out/bin/rars.jar "\$@"
    EOF
    chmod +x $out/bin/rars

  '';

  meta = {
    homepage = "https://github.com/TheThirdOne/rars";
    description = "RARS is the RISC-V Assembler and Runtime Simulator";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "rars";
  };
}
