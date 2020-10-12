{ stdenv, fetchFromGitHub, meson, ninja }:

stdenv.mkDerivation rec {
  version = "1.1.1";
  pname = "pfsshell";

  src = fetchFromGitHub {
    owner = "uyjulian";
    repo = "pfsshell";
    rev = "v${version}";
    sha256 = "0cr91al3knsbfim75rzl7rxdsglcc144x0nizn7q4jx5cad3zbn8";
  };

  nativeBuildInputs = [ meson ninja ];
  hardeningDisable = [ "format" "fortify" ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "PFS (PlayStation File System) shell for POSIX-based systems";
    platforms = platforms.unix;
    license = licenses.gpl2; #The APA, PFS, and iomanX libraries are licensed under the The Academic Free License version 2.
    maintainers = with maintainers; [ genesis ];
  };
}
