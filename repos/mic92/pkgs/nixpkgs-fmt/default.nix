{ stdenv, rustPlatform, fetchFromGitHub }: 

rustPlatform.buildRustPackage rec {
  pname = "nixpkgs-fmt";
  version = "2019-07-21";

  cargoSha256 = "1ihwhs6dgsp062f6d5qbv9khq6r15qq8np4wxg13nw11i8kdxm7d";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-fmt";
    rev = "1b9306e1f54ecda55c6aef661a3ab0220346376a";
    sha256 = "07f5kjpqdwlynrvmd54287sap6677c1249jpdyamip9hnpagr553";
  };

  meta = with stdenv.lib; {
    description = "Nix code formatter";
    homepage = https://github.com/nix-community/nixpkgs-fmt;
    license = licenses.mit;
  };
}
