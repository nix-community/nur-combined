{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "lnshot";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "ticky";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RkeLA1ieuDCJueDxgifef52yJr+DGCEMOAQ3hn9DieA=";
  };

  cargoHash = "sha256-jO90Y6Q7lwuhSEQXsTW8zcvoWjuM/bpy4V7kfqkv0/M=";

  meta = with lib; {
    description = "Symlink your Steam screenshots to a sensible place";
    homepage = "https://github.com/ticky/lnshot";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "lnshot";
  };
}
