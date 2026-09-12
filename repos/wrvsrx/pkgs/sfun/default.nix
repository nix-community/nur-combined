{
  stdenv,
  cmake,
  fetchFromGitHub,
  utfcpp,
  seal_lake,
}:
stdenv.mkDerivation rec {
  pname = "sfun";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "kamchatka-volcano";
    repo = "sfun";
    rev = "v${version}";
    hash = "sha256-/8HCmoKFyLrFPADzFRCUnx4bvGjrUx9IsdAit6uZhkg=";
  };
  patches = [ ./seal.patch ];
  prePatch = ''
    mkdir -p include/sfun/detail
    cp --no-preserve=mode,ownership -r ${utfcpp}/include/utf8cpp include/sfun/detail/external
    find include/sfun/detail/external -name '*.h' | xargs -d '\n' sed -i 's/namespace utf8/namespace sfun::utf8/g'
  '';
  buildInputs = [ seal_lake ];
  nativeBuildInputs = [ cmake ];
}
