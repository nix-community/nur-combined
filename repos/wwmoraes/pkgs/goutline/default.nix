{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "goutline";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "1pkg";
    repo = "goutline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cqsl8yWWKTWdVsFILBgucmVxysAuKU587SjEmi7Mrh8=";
  };

  patches = [ ./go-mod.patch ];

  vendorHash = "sha256-mvUnt+CQ02EPzrCTgf6Hcg5L9O2FWasLpFh/okk5tak=";

  meta = {
    description = "Go AST Declaration Extractor";
    homepage = "https://github.com/1pkg/goutline";
    license = lib.licenses.mit;
    mainProgram = "goutline";
    maintainers = with lib.maintainers; [ wwmoraes ];
    platforms = lib.platforms.all;
  };
})
