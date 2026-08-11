{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  installShellFiles,
  boost,
  zlib,
  openssl,
  upnpSupport ? true,
  miniupnpc,
}:

stdenv.mkDerivation rec {
  pname = "i2pd";
  version = "2.60.0-ed16cb";

  outputs = [ "out" "lib" "dev" ];

  src =
  # if true then /home/user/src/i2pd else
  fetchFromGitHub {
    owner = "PurpleI2P";
    repo = "i2pd";
    # tag = version;
    # https://github.com/PurpleI2P/i2pd/pull/2384
    # move files from build to repo root, install header files, install cmake files
    rev = "ed16cbf1708ff3ce2c92db062c99fee72bd7cdb6";
    hash = "sha256-Cy7RHeKJknxA2Gx21mopuqIkPNhrV+fN5ZOizY0y4UI=";
  };

  postPatch = lib.optionalString (!stdenv.hostPlatform.isx86) ''
    substituteInPlace Makefile.osx \
      --replace-fail "-msse" ""
  '';

  buildInputs = [
    boost
    zlib
    openssl
  ]
  ++ lib.optional upnpSupport miniupnpc;

  nativeBuildInputs = [
    cmake
    installShellFiles
  ];

  cmakeFlags = [
    "-DWITH_UPNP=${if upnpSupport then "yes" else "no"}"

    # fix: file RPATH_CHANGE could not write new RPATH:
    # The current RUNPATH does not contain /lib: as was expected
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"

    # "-DCMAKE_INSTALL_LIBDIR=lib"
    # "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  enableParallelBuilding = true;

  # TODO also install headers for $out/lib/libi2pd.a

  postInstall = ''
    # leave the build dir
    cd ..

    install --mode=444 -D 'contrib/i2pd.service' "$out/etc/systemd/system/i2pd.service"
    installManPage 'debian/i2pd.1'
    mkdir -p $out/share/doc/i2p
    # contrib: i2pd.conf tunnels.conf certificates ...
    cp -r contrib $out/share/doc/i2p

    moveToOutput lib $lib
    moveToOutput include $dev
    moveToOutput lib/cmake $dev
  '';

  meta = with lib; {
    homepage = "https://i2pd.website";
    description = "Minimal I2P router written in C++";
    license = licenses.bsd3;
    maintainers = with maintainers; [ edwtjo ];
    platforms = platforms.unix;
    mainProgram = "i2pd";
  };
}
