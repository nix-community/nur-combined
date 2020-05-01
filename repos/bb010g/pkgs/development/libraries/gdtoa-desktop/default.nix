{ stdenv, buildPackages, fetchFromGitHub
, enableRenamedFunctions ? false
}:

stdenv.mkDerivation rec {
  pname = "gdtoa-desktop-unstable";
  version = "2019-12-12";

  src = fetchFromGitHub {
    owner = "10110111";
    repo = "gdtoa-desktop";
    rev = "5c0663125d7704f7f9f8ef4b70c8567fa212f9cc";
    sha256 = "0fz6icxigvi7jqi0pjv19vgmmggcna6kr0ch0hm5si606w2qzwcq";
  };

  nativeBuildInputs = [ buildPackages.cmake ];

  patches = [
    ./cmake-pkgconfig.patch
  ];

  cmakeFlags =
    stdenv.lib.optionalString enableRenamedFunctions "-DRENAME_FUNCTIONS=ON";

  doInstallCheck = true;
  installCheckTarget = "check";

  meta = with stdenv.lib; {
    description =
      "Binary-decimal floating-point conversion library by David M. Gay";
    homepage = https://github.com/10110111/gdtoa-desktop;
    license = with licenses; mit;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
