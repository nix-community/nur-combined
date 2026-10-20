{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "pdfcraft";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "PDF editor for viewing, annotating and manipulating PDF documents";
    homepage = "https://getartcraft.com/apps/pdfcraft";
    maintainers = with lib.maintainers; [Prinky];
    license = with lib.licenses; [asl20 mit];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "pdfcraft";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "PdfCraft";
      categories = ["Graphics"];
      extraInstallCommands = ''
        chmod -R u+w $out/share/icons
        for file in $(find $out/share/icons -name 'ai.storyteller.${pname}.*'); do
          mv -f "$file" "$(dirname "$file")/${pname}.''${file##*.}"
        done
      '';
    }
