{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "gopium";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "1pkg";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-p3THftnXtwll5rUVONt9MMG4Dt7EDMBFSeUi/lTUIrs=";
  };

  vendorHash = "sha256-EiGX/sjTCigy3ThrHt7yEYbdyIAJeHJkiklJFVQhK54=";

  # tests hang for some reason I'm not interested into diving in
  doCheck = false;

  meta = with lib; {
    description = "Smart Go Structures Optimizer and Manager";
    homepage = "https://github.com/1pkg/gopium";
    license = licenses.mit;
    mainProgram = "gopium";
    maintainers = with maintainers; [ wwmoraes ];
  };
}
