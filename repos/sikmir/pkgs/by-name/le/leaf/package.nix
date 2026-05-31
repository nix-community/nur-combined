{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leaf";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    tag = finalAttrs.version;
    hash = "sha256-i9LVpNhSRXm4eW5xEOANZPCtnExPzgO+0fDZzg634Ic=";
  };

  cargoHash = "sha256-7iw2d5iySMtVUSWptqeO8ZSIMsufdiew6MsxA08PI7U=";

  meta = {
    description = "Terminal Markdown previewer";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "leaf";
  };
})
