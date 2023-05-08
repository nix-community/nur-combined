{ stdenv
, lib
,
}:

stdenv.mkDerivation {
  name = "am2rlauncher";
  pname = "am2rlauncher";


  meta = with lib; {
    license = licenses.gpl3;
    broken = true;
  };
}
