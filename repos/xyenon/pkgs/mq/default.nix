{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.2.2-unstable-2025-06-08";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "67f2c19470893379ce8e362c9d6a4ae69d2dcdd4";
    hash = "sha256-zhkV+FIzDoy9Tj7NDUPc/jmfQW2aRUj16W18FJnP+dE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-/5kDbdFcYHllWXwWKdxDHnfJtVGs/eq2uhbhhpclAW0=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
