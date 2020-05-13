{ stdenv, rustPlatform }:
rustPlatform.buildRustPackage rec {
  name = "slide-${version}";
  version = "0.1.0";

  src = ./.;

  cargoSha256 = "0ys6znjfanb25shfqa9v7fj2gmf3ai590pi98d1v4mb06r5dnlz7";

  meta = with stdenv.lib; {
    description = "Generate sliding windows of words";
    homepage = https://github.com/kmein/slide;
    license = licenses.mit;
    maintainers = [ maintainers.kmein ];
    platforms = platforms.all;
  };
}
