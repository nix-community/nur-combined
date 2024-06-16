{
  lib,
  stdenv,
  fetchFromGitHub,
  pcre,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "csvtools";
  version = "0-unstable-2023-10-10";

  src = fetchFromGitHub {
    owner = "DavyLandman";
    repo = "csvtools";
    rev = "0162d828ec7500cf01080f73fd28387a9cdada92";
    hash = "sha256-avdnbdKh/GFibIFfKmmLLcZOvijnQmJb5VNgaZA+NiY=";
  };

  buildInputs = [ pcre ];

  makeFlags = [ "prefix=$(out)" ];
  enableParallelBuilding = true;

  doCheck = false; # Failed (csvawk crashed)
  nativeCheckInputs = [ openssl ];

  preCheck = "patchShebangs .";

  preInstall = "mkdir -p $out/bin";

  meta = {
    description = "GNU-alike tools for parsing RFC 4180 CSVs at high speed";
    homepage = "https://github.com/DavyLandman/csvtools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
