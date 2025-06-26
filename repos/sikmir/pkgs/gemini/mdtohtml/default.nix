{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "mdtohtml";
  version = "0.1.3";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = "mdtohtml";
    rev = finalAttrs.version;
    hash = "sha256-qvd4Iz+1uNT1Y/DkHGRYBVCLeIpleQ58Ua4eSYv+ilQ=";
  };

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  vendorHash = "sha256-b+xQpGSN6F79qTDqVpyEsEQGNgcR1/l7pzwIxqgTcic=";

  postBuild = ''
    scdoc < docs/mdtohtml.1.scd > docs/mdtohtml.1
  '';

  postInstall = ''
    installManPage docs/mdtohtml.1
  '';

  meta = {
    description = "Markdown to HTML converter";
    homepage = "https://git.sr.ht/~adnano/mdtohtml";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mdtohtml";
  };
})
