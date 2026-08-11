{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "diskhash";
  version = "unstable-2024-07-17";

  src = fetchFromGitHub {
    owner = "nanocurrency";
    repo = "diskhash";
    # https://github.com/nanocurrency/diskhash/pull/9
    rev = "eba18323495ea22b6560be0dc7c001250c176892";
    hash = "sha256-TmS/+nj8FzMDCmh8Rh6HT1NOrIFacYuVGDj4L66L0kA=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    # dont build tests:
    # cpp_slow_tests diskhash_tests disktest os_wrappers_tests cpp_wrapper_tests
    "-DDISKHASH_TESTS=OFF"
  ];

  meta = with lib; {
    description = "Diskbased (persistent) hashtable";
    homepage = "https://github.com/nanocurrency/diskhash";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
