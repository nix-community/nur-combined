{
  lib,
  buildGoModule,
}:
buildGoModule {
  name = "carddav-immich-bday-sync";
  meta = {
    description = "Sync the birthdays of your contacts on a CardDAV server to your immich instance.";
    homepage = "https://codeberg.org/someron/nur/src/branch/main/pkgs/carddav-immich-bday-sync/src";
    license = lib.licenses.mit;
    mainProgram = "carddav-immich-bday-sync";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  src = ./src;

  vendorHash = "sha256-e+KGALrpqKaWfbjl1WJ6shqM9opDJCL2WTHP6iWcECA=";
}
