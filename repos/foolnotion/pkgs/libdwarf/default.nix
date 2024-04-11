{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "0.9.2";

  src = fetchFromGitHub {
    #owner = "jeremy-rifkin";
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${version}";
    hash = "sha256-z5JIf8Qybu1IiuQeFjPvrh8b22l/RagYZRPJRv6rBws=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    homepage = "https://github.com/jeremy-rifkin/libdwarf-code";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
  };
}
