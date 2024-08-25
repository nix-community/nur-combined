{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "mobroute";
  version = "0.6.0";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobroute";
    rev = "v${version}";
    hash = "sha256-Wh+fVKB/rQixqRe23QVbrIvL1er7tgQHuixgTEn/aVI=";
  };

  vendorHash = "sha256-N13tDUQ9XKfPXV7vTHXdrFWlmaXAGMCnSL2YiPBdQaw=";

  tags = [ "sqlite_math_functions" ];

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
  };
}
