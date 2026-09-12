{
  stdenv,
  cmake,
  fetchFromGitHub,
  sfun,
  seal_lake,
}:
stdenv.mkDerivation rec {
  pname = "cmdlime";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "kamchatka-volcano";
    repo = "cmdlime";
    rev = "v${version}";
    hash = "sha256-D29j9AfAL9y7YEZYqiAIAcB2BPlHxLUUZHy0ied8OTk=";
  };
  patches = [ ./seal.patch ];
  prePatch = ''
    mkdir -p include/cmdlime/detail/external
    cp --no-preserve=mode,ownership -r ${sfun}/include/sfun include/cmdlime/detail/external/sfun
    find include/cmdlime/detail/external -name '*.h' | xargs -d '\n' sed -i 's/namespace sfun/namespace cmdlime::sfun/g'
  '';
  buildInputs = [ seal_lake ];
  nativeBuildInputs = [ cmake ];
}
