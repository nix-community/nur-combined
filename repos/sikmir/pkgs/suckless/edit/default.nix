{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "edit";
  version = "2023-10-11";

  src = fetchFromGitHub {
    owner = "arthur-jacquin";
    repo = "edit";
    rev = "d2a9b26f21e45b699afb99180238f90055cd7332";
    hash = "sha256-pXo5HnfJPpiXw7RApvaQcl4xvosUnyi3ov43dLcym48=";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace-fail "LDFLAGS" "#LDFLAGS"
  '';

  makeFlags = [ "CC:=$(CC)" "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A suckless, simple, featured text editor";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
