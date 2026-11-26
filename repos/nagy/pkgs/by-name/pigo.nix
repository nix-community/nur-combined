{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pigo";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "esimov";
    repo = "pigo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0URCxLdKVOMoA8Pfw0WR4Qd84O/fE8s1cPb6cI0i6QM=";
  };

  vendorHash = "sha256-492moVBnRSMwU2UH3mEtOh/FmnznSChYBSZtukVVtvM=";

  # Upstream moved the library from `core`/`cascade` to `pkg` in 1.5.0 and
  # dropped `demos/native`, but these example commands still import it, so
  # `go mod download` fails for the module as a whole.
  postPatch = ''
    rm -rf examples/native
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/http $out/bin/pigo-http
  '';

  meta = {
    description = "Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go";
    homepage = "https://github.com/esimov/pigo";
    license = lib.licenses.mit;
    mainProgram = "pigo";
    maintainers = with lib.maintainers; [ nagy ];
  };
})
