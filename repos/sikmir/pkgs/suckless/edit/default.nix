{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "edit";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "arthur-jacquin";
    repo = "edit";
    rev = "db569efc2a3460591a44b7144769857292bdbe88";
    hash = "sha256-q2E/XWARm6aek6E81fOb9gOpumEWxmtB1Ni5hHoQOkY=";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace "LDFLAGS" "#LDFLAGS"
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A suckless, simple, featured text editor";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
