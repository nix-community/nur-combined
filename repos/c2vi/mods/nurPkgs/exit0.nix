{ stdenv
, fetchFromGitHub
, meson
, lib
, ninja
}:

stdenv.mkDerivation rec {
	name = "exit0";

	src = fetchFromGitHub {
		owner = "richardweinberger";
		repo = "exit0";
    rev = "f6cdeeb858ad9717b698a21e6fec3bb94b2aa2dd";
    sha256 = "sha256-NCNPO4XCdCwPLSQuW4AT6vskqvu1ks/yHGUzzI+l3hE=";
	};

  nativeBuildInputs = [
    meson
    ninja
  ];
  
  buildInputs = [
  ];

  meta = with lib; {
    description = "Kill programs so that they exit with a 0 exit code, by injecting code with debug apis";
    longDescription = ''
      Killing programs results into non-zero exit codes and monitoring/parent processes will notice. There are situations where you want to forcefully kill a program but make it look like a graceful exit.

      Further reading: https://sigma-star.at/blog/2024/02/exit0-code-injection/
    '';
    homepage = "https://github.com/richardweinberger/exit0";
    license = licenses.gpl2Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
