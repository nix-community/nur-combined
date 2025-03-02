{fetchzip, lib, xpenguins, maintainers}: fetchzip {
    pname = "xpenguins-themes-unfree";
    version = "1.0";
    url = "http://xpenguins.seul.org/xpenguins_themes-1.0.tar.gz";
    stripRoot = false;
    postFetch = ''
        mkdir -p "$out/share/xpenguins"
        mv "$out/themes" "$out/share/xpenguins/themes"
    '';
    hash = "sha256-m7HrTK9K13B7nIfFUPEcSU5ZDcs8tFr3pYNC8biYIdY=";
    meta = {
        description = "Extra themes for xpenguins";
        inherit (xpenguins) homepage;
        license = lib.licenses.unfree;
        maintainers = [maintainers.Rhys-T];
    };
}
