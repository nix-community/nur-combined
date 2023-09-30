{ stdenvNoCC, lib, fetchFromSourcehut }:

stdenvNoCC.mkDerivation rec {
  pname = "bollux";
  version = "0.4.3";

  src = fetchFromSourcehut {
    owner = "~acdw";
    repo = pname;
    rev = version;
    hash = "sha256-BpbxgqIC1s6ur5UTE2TBKMLV62FFDYBMHGY3FuDB/A8=";
  };

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "gemini browser in like, bash?";
    license = licenses.mit;
  };
}
