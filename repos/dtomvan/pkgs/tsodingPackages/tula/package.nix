{
  lib,
  rustPlatform,
  fetchFromGitHub,
  python3,
}:
rustPlatform.buildRustPackage {
  pname = "tula";
  version = "0-unstable-2024-06-26";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "tula";
    rev = "e77e05a70b91f3fc936895db924c974fc51b4ba3";
    hash = "sha256-Fun7qsT2utcWzm22tELexi6afD3AndxdhUqaLJHLN4E=";
  };

  doCheck = true;

  checkPhase = ''
    ${lib.getExe python3} ./rere.py replay ./tests.list
  '';

  cargoHash = "sha256-ADfthz5qhGDxcYjPzeRwY7UVtgEi91piVA+tKDdBT+U=";

  meta = {
    description = "Turing Language";
    homepage = "https://github.com/tsoding/tula";
    license = lib.licenses.mit;
    mainProgram = "tula";
  };
}
