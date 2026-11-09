{ maintainers
, pkgs
, ...
}: let
    lib = pkgs.lib;

    pname = "docx-cli";
    version = "0.29.0";

    releaseAssets = {
        "x86_64-linux" = {
            name = "docx-linux-x64";
            hash = "sha256-5w99k3PKpsqV/1ZnrOdnRqmqsqUSh7/v/uKZp8xY0WY=";
        };
        "aarch64-linux" = {
            name = "docx-linux-arm64";
            hash = "sha256-6EJfkA2I78FTz8+rQ7l5duGGYX39oNZxlLQPYqF9d+k=";
        };
    };

    releaseAsset = releaseAssets.${pkgs.stdenv.hostPlatform.system};
    releaseUrl = name: "https://github.com/kklimuk/docx-cli/releases/download/v${version}/${name}";

    releaseFile = name: hash: pkgs.fetchurl {
        url = releaseUrl name;
        inherit hash;
    };

    licenseFile = releaseFile "LICENSE" "sha256-f6ezxle0rDNwB1xUBPqXrCw46oYxuub1k4tew6rECnU=";
    noticesFile = releaseFile "NOTICES" "sha256-PhYn5nV0HEWPpMHQEm6SBhyPzKq+PRNAfP+oWkd1/OE=";
    lgplFile = releaseFile "LGPL-3.0.txt" "sha256-46mU2C5kSwOnkqkw9XQAJlhBL2JAf1/uCD8lVcXyMRg=";
in
pkgs.stdenvNoCC.mkDerivation {
    inherit pname version;

    src = releaseFile releaseAsset.name releaseAsset.hash;
    dontUnpack = true;
    dontStrip = true;

    nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
    ];

    buildInputs = [ pkgs.glibc ];

    installPhase = ''
        runHook preInstall

        install -Dm755 "$src" "$out/bin/docx"
        install -Dm644 ${licenseFile} "$out/share/doc/${pname}/LICENSE"
        install -Dm644 ${noticesFile} "$out/share/doc/${pname}/NOTICES"
        install -Dm644 ${lgplFile} "$out/share/doc/${pname}/LGPL-3.0.txt"

        runHook postInstall
    '';

    postFixup = ''
        wrapProgram "$out/bin/docx" \
            --prefix PATH : ${lib.makeBinPath [ pkgs.libreoffice ]}
    '';

    passthru = {
        inherit releaseAsset;
    };

    meta = with lib; {
        description = "CLI for reading, editing, and rendering Word documents";
        homepage = "https://github.com/kklimuk/docx-cli";
        license = [ licenses.mit licenses.asl20 licenses.bsd3 licenses.lgpl3Only ];
        maintainers = [ maintainers.srcres258 ];
        mainProgram = "docx";
        platforms = builtins.attrNames releaseAssets;
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    };
}
