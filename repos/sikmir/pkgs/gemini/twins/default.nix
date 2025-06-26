{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule (finalAttrs: {
  pname = "twins";
  version = "1.0.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "tslocum";
    repo = "twins";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kq1qhWx0kwvW8I+hUz0MgbOTaS/vSfdwkt56RZ7eAVk=";
  };

  vendorHash = "sha256-XwQJjTxKlbJjbq556jXWBx2BNpKxGJmwoR1om005mb0=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Gemini server";
    homepage = "https://codeberg.org/tslocum/twins";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "twins";
  };
})
