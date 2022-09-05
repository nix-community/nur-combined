{ lib
, resholve
, fetchzip
, bash
, asciidoc
, coreutils
, curl
, gawk
, git
, gnum4
, gnutar
, jq
, libarchive
, rp ? ""
}:

resholve.mkDerivation rec {
  pname = "asp";
  version = "8";

  src = fetchzip {
    url = "${rp}https://github.com/archlinux/${pname}/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-UuWdWu+tBLm/Tf4gC0UUcVcx3vQ+Gp359U+qV8CAH54=";
  };

  nativeBuildInputs = [ asciidoc gnum4 ];

  installFlags = [ "PREFIX=$(out)" ];

  solutions.profile = {
    scripts = [ "bin/asp" ];
    interpreter = "${bash}/bin/bash";
    inputs = [ coreutils curl gawk git gnutar jq ];
    keep = [ "$dumpfn" "$candidates" ];
    execer = [ "cannot:${git}/bin/git" ];
  };

  meta = with lib; {
    description = "Arch Linux build source file management tool";
    homepage = "https://github.com/falconindy/asp";
    license = licenses.mit;
  };
}