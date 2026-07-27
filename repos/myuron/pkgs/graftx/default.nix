{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "graftx";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "myuron";
    repo = "graftx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OqkcbzIiYBp4jP7lzYOBkg7pBt6pg8qTCAM+iFLd5wY=";
  };

  vendorHash = "sha256-TUbaUoqDZoQTkcOMtoE/FlAiqkWN+x49JeGkDguh2UU=";

  # Tests read the home directory, which is unavailable in the sandbox.
  doCheck = false;

  meta = {
    description = "TUI file manager that accelerates file copying between repositories";
    homepage = "https://github.com/myuron/graftx";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "graftx";
    maintainers = [ ];
  };
})
