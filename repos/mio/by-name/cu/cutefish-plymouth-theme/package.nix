{
  mkCutefishDerivation,
  lib,
}:

mkCutefishDerivation {
  pname = "cutefish-plymouth-theme";

  # Data only: the boot splash and the boot menu themes, no build step.
  dontConfigure = true;
  dontBuild = true;

  # The theme file names the installed directory, which is /usr upstream.
  postPatch = ''
    substituteInPlace cutefish-logo/cutefish-logo.plymouth \
      --replace-fail /usr/share/plymouth/themes/cutefish-logo \
        ${placeholder "out"}/share/plymouth/themes/cutefish-logo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes $out/share/grub/themes
    cp -a cutefish-logo cutefish-text $out/share/plymouth/themes/
    cp -a grub/cutefish $out/share/grub/themes/
    runHook postInstall
  '';

  meta = {
    description = "Plymouth boot splash and GRUB boot menu themes for the Cutefish desktop";
    license = lib.licenses.gpl3Plus;
  };
}
