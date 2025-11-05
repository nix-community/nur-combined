{
  buildGoModule,
  lib,
  source,
}:
buildGoModule rec {
  pname = "kanata-tray";
  inherit (source) src version;
  vendorHash = "sha256-tW8NszrttoohW4jExWxI1sNxRqR8PaDztplIYiDoOP8=";

  meta = {
    platforms = lib.platforms.unix;
  };
}
