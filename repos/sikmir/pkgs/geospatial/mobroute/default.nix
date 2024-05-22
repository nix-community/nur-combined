{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule rec {
  pname = "mobroute";
  version = "0.4.0";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobroute";
    rev = "v${version}";
    hash = "sha256-CS4nHzK/WvnwHGfYGXGR8LsyndM5SFOcK5RS4hqmRps=";
  };

  vendorHash = "sha256-PFiHfWTK2XT6/rK96myNwNS9gBWsEjVS5J3E2rEvRKk=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "Minimal FOSS Public Transportation Router";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "mobroute";
  };
}
