pkgs: rec {
    mkZoteroAddon =
        {
            stdenvNoCC ? pkgs.stdenvNoCC,
            pname,
            version,
            src,
            addonId,
            meta ? { },
            ...
        }:
        stdenvNoCC.mkDerivation {
            inherit pname version src;

            preferLocalBuild = true;
            allowSubstitutes = true;

            buildCommand = ''
                dst="$out/share/zotero/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
                mkdir -p "$dst"
                install -v -m644 "$src" "$dst/${addonId}.xpi"
            '';

            inherit meta;
        };

    callYaziPlugin = x: y: pkgs.callPackage x (y // { inherit (pkgs.yaziPlugins) mkYaziPlugin; });

    callZoteroAddon = x: y: pkgs.callPackage x (y // { inherit mkZoteroAddon; });
}
