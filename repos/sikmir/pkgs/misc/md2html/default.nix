{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "md2html";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "nocd5";
    repo = "md2html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3DnCLoX0x872zB90Z172iGwc6kQk9tpG1drw4s7LI0o=";
  };

  vendorHash = "sha256-XO8WD/SC2Xii0bUiuOGL9V7XgTJDZjsPrpmyONFm+7U=";

  meta = {
    description = "Markdown to single HTML";
    homepage = "https://github.com/nocd5/md2html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
