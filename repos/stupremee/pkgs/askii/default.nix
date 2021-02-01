{ rustPlatform, lib, fetchFromGitHub, python3, libxcb, ... }:
rustPlatform.buildRustPackage rec {
  pname = "askii";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Stupremee";
    repo = pname;
    rev = "master";
    sha256 = "sha256-DWHbTaxOMY562LlWbwGr1dJzMqfI434yEKwXdL+poh4=";
  };

  nativeBuildInputs = [ python3 ];
  buildInputs = [ libxcb ];

  cargoSha256 = "sha256-25kAr+EDdWeNZ6cRQE827l692Hyfy4D04GOAqHAxGEQ=";

  meta = with lib; {
    description = "TUI based ASCII diagram editor.";
    homepage = "https://github.com/nytopop/askii";
    license = licenses.asl20;
  };
}
