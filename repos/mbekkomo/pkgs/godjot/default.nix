{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "godjot";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "sivukhin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-C9GvqjtGvRlJciCxQKc0jreRtwnjsD1deu3T4icPOQs=";
  };

  vendorHash = "sha256-khVWMKa5ejdKCR9IW20NOOJofodPF/1nErsrIfQXIlU=";

  checkPhase = "true";

  meta = {
    description = "Djot markup language parser implemented in Go language";
    homepage = "https://github.com/sivukhin/godjot#readme";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
