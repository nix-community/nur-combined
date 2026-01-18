{
    stdenvNoCC,
    fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
    pname = "actually-all-emojis-spaces";
    version = "unstable-2023-06-22";

    src = fetchFromGitHub {
        owner = "jobiewong";
        repo = "espanso-emojis";
        rev = "88ba2b715edaef0ce26238684edc62221d9a7c67";
        sparseCheckout = [ "espanso_package/actually-all-emojis-spaces/0.3.0" ];
        hash = "sha256-Wq7q1Si6qHww/boUZuiYtqtrDG3v6rxsfmoEJSLGH5Y=";
    };

    installPhase = ''
        cp -r espanso_package/actually-all-emojis-spaces/0.3.0 $out
    '';

    meta = {
        homepage = "https://github.com/jobiewong/espanso-emojis";
    };
}
