{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "hello";
  version = "version";

  src = lib.cleanSource ./.;

  vendorHash = null;

  meta = with lib; {
    description = "My program";
    homepage = "https://github.com/myrepo/myprogram";
    licenses = licenses.gpl3Only;
    mainProgram = "hello";
  };
}
