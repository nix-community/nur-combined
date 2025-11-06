{
    sources,
    stdenvNoCC,
}: let
    inherit (sources.SFMono-Nerd-Font-Ligaturized) src pname date;
in
    stdenvNoCC.mkDerivation {
        inherit pname src;
        version = date;

        phases = ["unpackPhase" "installPhase"];
        dontConfigure = true;

        installPhase = ''
            install -Dm644 ./*.otf -t $out/share/fonts/opentype
        '';

        meta = {
            description = "Apple's SFMono font nerd-font patched and ligaturized";
            homepage = "https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized";
        };
    }
