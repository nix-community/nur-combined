{
    stdenvNoCC,
    fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
    pname = "SFMono-Nerd-Font-Ligaturized";
    version = "0-unstable-2023-07-02";

    src = fetchFromGitHub {
        owner = "shaunsingh";
        repo = "SFMono-Nerd-Font-Ligaturized";
        rev = "dc5a3e6fcc2e16ad476b7be3c3c17c2273b260ea";
        fetchSubmodules = false;
        sha256 = "sha256-AYjKrVLISsJWXN6Cj74wXmbJtREkFDYOCRw1t2nVH2w=";
    };

    phases = [
        "unpackPhase"
        "installPhase"
    ];
    dontConfigure = true;

    installPhase = ''
        install -Dm644 ./*.otf -t $out/share/fonts/opentype
    '';

    meta = {
        description = "Apple's SFMono font nerd-font patched and ligaturized";
        homepage = "https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized";
    };
}
