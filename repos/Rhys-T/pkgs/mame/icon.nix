{ stdenvNoCC, papirus-icon-theme }: stdenvNoCC.mkDerivation {
    pname = "mame-icon-from-${papirus-icon-theme.pname}";
    inherit (papirus-icon-theme) version src;
    dontUnpack = true;
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/share/icons/Papirus/32x32/apps
        cp "$src"/Papirus/32x32/apps/mame.svg "$out"/share/icons/Papirus/32x32/apps/mame.svg
        runHook postInstall
    '';
    meta.license = papirus-icon-theme.meta.license;
}
