{
  lib,
  stdenv,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "gelim";
  version = "0.13.1";

  src = fetchFromSourcehut {
    owner = "~hedy";
    repo = "gelim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cP0dqgoe8P8W3qKTmDHSUhCLCBoPUvN/EMWql073rf0=";
  };

  patches = [ ./go.mod.patch ];

  nativeBuildInputs = [
    scdoc
    installShellFiles
  ];

  vendorHash = "sha256-MOdAUPAvodDdYE3f9CvodFCTYVcB0AUbt8T4FcYZWYc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  postBuild = ''
    scdoc < gelim.1.scd > gelim.1
  '';

  postInstall = ''
    installManPage gelim.1
  '';

  meta = {
    description = "A minimalist line-mode smolnet client written in go";
    homepage = "https://sr.ht/~hedy/gelim/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "gelim";
  };
})
