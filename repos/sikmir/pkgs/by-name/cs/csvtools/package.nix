{
  lib,
  stdenv,
  fetchFromGitHub,
  pcre2,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "csvtools";
  version = "0-unstable-2025-09-03";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "DavyLandman";
    repo = "csvtools";
    rev = "8e1d2390851dad38ea87950762006e1bf9e642aa";
    hash = "sha256-Ndz4Cqh7pIru+NzNvlU9Uek5Ke7i40AeJXrw4e0FGns=";
  };

  buildInputs = [ pcre2 ];

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
    broken = true;
  };
})
