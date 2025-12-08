{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "bunnyfetch";
  version = "unstable-2022-01-12";

  src = fetchFromGitHub {
    owner = "devins2518";
    repo = pname;
    rev = "dae88dc91e6cf7ab67f8da319028759eb0738e99";
    sha256 = "sha256-dzX1NmSI8Gw/WzKc/gymqj8u0teJPivxnkkRG9j2AXU";
  };

  cargoHash = "sha256-Ec8hLtWEkwMRf3wApnVeqLkNg8QwYi9mwINK4V76YTA=";

  meta = with lib; {
    description = "Tiny system info fetch utility. ";
    homepage = "https://github.com/devins2518/bunnyfetch";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
