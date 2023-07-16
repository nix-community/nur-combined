{ stdenvNoCC
, lib
, undmg
, unzip
}:

stdenvNoCC.mkDerivation rec {
  name = "wikit";
  version = "0.5.0";

  src = builtins.fetchurl {
    url = "https://github.com/ikey4u/wikit/releases/download/${version}/wikit-darwin.zip";
    sha256 = "0qdli8490h4z3a5xzs40620r5vxy25qvr7409rrgwa7pyw73lci8";
  };

  buildInputs = [ undmg unzip ];
  installPhase = ''
    runHook preInstall

    undmg "Wikit Desktop_${version}_x64.dmg"
    mkdir -p $out/{Applications,bin}
    cp -R "Wikit Desktop.app" $out/Applications
    install wikit $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wikit - A universal lookup tool";
    homepage = "https://github.com/ikey4u/wikit";
    maintainers = with maintainers; [ congee ];
    licenses = licenses.mit;
    platforms = platforms.darwin;
  };
}
