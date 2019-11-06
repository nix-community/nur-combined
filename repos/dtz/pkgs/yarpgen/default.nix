{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "yarpgen";
  version = "unstable-2019-09-16";

  src = fetchFromGitHub {
    owner = "intel";
    repo = pname;
    rev = "771d6f608ee2d51c1757b6e485c096c7177e04c6";
    sha256 = "0mxnxrc21h1z8nq2g8331p3bdhkffwddrask3wqc0czb6fgsnnkr";
  };

  nativeBuildInputs = [ cmake ];

  # Install the main executable, at least
  # TODO: install run_gen.py and its supporting cast of files and deps.
  # https://github.com/intel/yarpgen/blob/master/run_gen.py
  #
  # - [ ] Patchup py3 usage with suitable packages available
  # - [ ] substitute paths to runtime deps such as creduce (!)
  # - [ ] investigate role of "Software Development Emulator" mentioned in README.md
  #
  installPhase = ''
    install -Dm755 -t $out/bin ${pname}
  '';

  meta = with stdenv.lib; {
    description = "Yet Another Random Program Generator";
    license = licenses.asl20;
    homepage = "https://github.com/intel/yarpgen";
    maintainers = with maintainers; [ dtzWill ];
  };
}
