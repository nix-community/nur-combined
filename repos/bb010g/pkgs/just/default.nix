{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "just-${version}";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "casey";
    repo = "just";
    rev = "v${version}";
    sha256 = "1n1448vrigz6jc73b3abq53lpwcggdwq93cjxqb2hn87qcqlyii7";
  };

  cargoSha256 = "0awfq9fhcin2q6mvv54xw6i6pxhdp9xa1cpx3jmpf3a6h8l6s9wp";

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Just a command runner";
    homepage = https://github.com/casey/just;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}

