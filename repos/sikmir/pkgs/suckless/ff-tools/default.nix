{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ff-tools";
  version = "0-unstable-2019-06-08";

  src = fetchFromGitHub {
    owner = "sirjofri";
    repo = "ff-tools";
    rev = "ca02af149a0915caae2c4b8de39baac21d3e596b";
    hash = "sha256-V++8FI8u7N9ALDjoAyd/wD7vg/43E9D/wuwwKiB1NfQ=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/bin";

  meta = {
    description = "A collection of farbfeld tools";
    homepage = "https://github.com/sirjofri/ff-tools";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
