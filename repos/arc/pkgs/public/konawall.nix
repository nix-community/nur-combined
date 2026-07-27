{ fetchFromGitHub, rustPlatform, lib, pkg-config, openssl, libX11, libXrandr }: rustPlatform.buildRustPackage rec {
  pname = "konawall-rs";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kittywitch";
    repo = pname;
    rev = "aeb6688100c918f261c8b561867866e6825e2a39";
    sha256 = "0srw4cy8livxqjdswdi10q79gak5jqc0mhfy9j5f8sy21w701jr0";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl libX11 libXrandr ];

  meta = with lib; {
    platforms = platforms.linux;
  };

  cargoHash = "sha256-whtZk+q+rC46rqqbaFaTCkyoMyfyQjyHa0EjYBNvHhM=";
}
