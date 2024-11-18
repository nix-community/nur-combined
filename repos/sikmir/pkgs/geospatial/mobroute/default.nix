{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  sqlite,
}:

buildGoModule rec {
  pname = "mobroute";
  version = "0.8.2";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobroute";
    rev = "v${version}";
    hash = "sha256-5Psbux1Zn6VXcBgyqlO1IboVjUVz8cC+Hoy4Qxm6XgM=";
  };

  vendorHash = "sha256-16+AiKFXgXYg2AcDhpfT8o7tw5J8NYJGyKR4TsGCj/o=";

  tags = [ "sqlite_math_functions" ];

  buildInputs = [ sqlite ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    mv $out/bin/{cli,mobroute}
  '';

  meta = {
    description = "Minimal FOSS Public Transportation Router";
    homepage = "https://sr.ht/~mil/mobroute";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mobroute";
    skip.ci = true;
  };
}
