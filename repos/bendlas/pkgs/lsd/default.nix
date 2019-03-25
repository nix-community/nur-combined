{ stdenv, rustPlatform, fetchFromGitHub }:

# stdenv.mkDerivation rec {
#   name = "lsd-${version}";
#   version = "0.14.0";
#   src = ./.;
#   buildPhase = "echo echo Hello World > example";
#   installPhase = "install -Dm755 example $out";
# }

rustPlatform.buildRustPackage rec {
  name = "lsd-${version}";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "Peltoche";
    repo = "lsd";
    rev = "${version}";
    sha256 = "1k054c4mz0z9knfn7kvvs3305z2g2w44l0cjg4k3cax06ic1grlr";
  };

  cargoSha256 = "0pg4wsk2qaljrqklnl5p3iv83314wmybyxsn1prvsjsl4b64mil9";

  meta = with stdenv.lib; {
    description = "The next gen ls command";
    homepage = https://github.com/Peltoche/lsd;
    license = licenses.asl20;
    maintainers = [ maintainers.bendlas ];
    platforms = platforms.all;
  };
}
