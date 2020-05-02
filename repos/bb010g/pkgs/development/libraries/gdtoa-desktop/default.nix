{ stdenv, buildPackages, fetchFromGitHub
, enableRenamedFunctions ? false
}:

stdenv.mkDerivation rec {
  pname = "gdtoa-desktop-unstable";
  version = "2020-05-01";

  src = fetchFromGitHub {
    owner = "10110111";
    repo = "gdtoa-desktop";
    rev = "c178e2c44d3644440f3502d0934ffce53bcab9b5";
    sha256 = "0kmafzyh14msxraprcx9gq55904icfqns16nanxfpa4ml3cdx1ib";
  };

  nativeBuildInputs = [ buildPackages.cmake ];

  cmakeFlags =
    stdenv.lib.optionalString enableRenamedFunctions "-DRENAME_FUNCTIONS=ON";

  doInstallCheck = true;
  installCheckTarget = "check";

  meta = with stdenv.lib; {
    description =
      "Binary-decimal floating-point conversion library by David M. Gay";
    homepage = "https://github.com/10110111/gdtoa-desktop";
    license = with licenses; mit;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
