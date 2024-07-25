{lib, stdenv, fetchurl}: 

stdenv.mkDerivation rec {

    pname = "vscode-codicons";
    version = "0.0.36";

    hash = "sha256-NgUnV1OVrXD5QO/x5D63wuxk9OafidxYYbc0INKlePA=";

    src = fetchurl {
        url = "https://github.com/microsoft/${pname}/releases/download/${version}/codicon.ttf";
        inherit hash;
    };

    unpackPhase = " ";

    installPhase = ''
        mkdir -p $out/share/fonts/truetype

        ln -s $src $out/share/fonts/truetype/codicon.ttf
    '';

    
    meta =  {
        description = "Microsoft VSCode Codicons font";
        homepage = "https://github.com/microsoft/vscode-codicons";
        license = with lib.licenses; [ mit cc-by-40];
        # provanace TODO this should be some sort of binary provanance
    };

}


