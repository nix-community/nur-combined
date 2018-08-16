{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "diva-${version}";
  version = "2018-01-24";

  src = fetchFromGitHub {
    owner = "SNSystems";
    repo = "DIVA";
    rev = "fdc066d84f5599427ecc6eb71fd7648ea8833b37";
    sha256 = "1lsb6zi21li0vx7p5izj8gjpnqq2pjff4s337il0xsn243mmdr96";
  };

  nativeBuildInputs = [ cmake ];

  postUnpack = ''
    sourceRoot=$sourceRoot/DIVA
  '';

  cmakeFlags = [ ''-Ddeploy_dir=''${out}'' ];

  enableParallelBuilding = true;

  installTargets = [ "DEPLOY" ];

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/*.so $out/lib/
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$out/lib \
    ./bin/unittests
  '';

  # TODO: Build dependencies from source as well,
  # instead of using the bundled pre-built libraries :(

  meta = with stdenv.lib; {
    description = "Debug Information Visual Analyzer";
    homepage = https://github.com/SNSystems/DIVA;
    license = licenses.unfree; # XXX ?
    maintainers = with maintainers; [ dtzWill ];
  };
}
