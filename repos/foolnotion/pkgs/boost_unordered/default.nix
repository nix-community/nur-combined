{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "boost_unordered";
  version = "1.87.1";

  src = fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "boost_unordered";
    rev = "v${version}";
    hash = "sha256-abMXIEKXl+lBuyebnY0JaeGa3MMuvXpvfr5arQOgwcE=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUS_INCLUDE_TESTS=OFF" ];

  patches = [ ./cmake_install_rules.patch ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Standalone version of the boost::unordered library";
    homepage = "https://github.com/MikePopoloski/boost_unordered";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
