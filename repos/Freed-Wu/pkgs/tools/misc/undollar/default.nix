{ mySources
, lib
, stdenv
, cmake
}:
stdenv.mkDerivation rec {
  inherit (mySources.undollar) pname version src;

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/undollar";
    description = "strip the dollar sign from the beginning of the terminal command";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
