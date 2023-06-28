{ stdenv, lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "complgen";
  version = "2023-06-28";

  src = fetchFromGitHub {
    owner = "adaszko";
    repo = "complgen";
    rev = "168e56f056613e1d4977237400dd7f7e92f84112";
    hash = "sha256-IRbQ8fNxy4jwSevxBhrP5ADWrO4NPYP/mnvhQr8cNCk=";
  };

  cargoHash = "sha256-0RnOjNYLnDwmzTXcjt4k4VxPR+XcKBovYENabKlK1lo=";

  meta = with lib; {
    description = "Generate shell completions based on a BNF-like grammar";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
