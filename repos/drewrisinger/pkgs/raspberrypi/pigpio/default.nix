{ stdenv
, lib
, fetchFromGitHub
, cmake
}:

# C libraries & daemon for pigpio
stdenv.mkDerivation rec {
  pname = "pigpio";
  version = "78";

  src = fetchFromGitHub {
    owner = "joan2937";
    repo = "pigpio";
    rev = "v${version}";
    sha256 = "0x628bsjb8iqnjvmz3bs0k0jc9m14yq0grfnsnwr53fs6fprh0wr";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C library for the Raspberry Pi which allows control of the General Purpose Input Outputs (GPIO)";
    homepage = "http://abyz.me.uk/rpi/pigpio/";
    license = licenses.unlicense;
    platforms = [ "aarch64-linux" "armv7l-linux" ]; # targeted at Raspberry Pi ONLY
    maintainers = [ maintainers.drewrisinger ];
  };
}
