{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "hponcfg";
  version = "5.6.0-0";

  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/mcp/centos/8/x86_64/current/${pname}-${version}.x86_64.rpm";
    sha256 = "0cjzslclli79z2vpah7ksckpi7as1ay65qi5b5ds612mp95d1c0w";
  };

  nativeBuildInputs = [
    rpmextract autoPatchelfHook
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  # TODO: Use install instead of cp
  installPhase = ''
    runHook preInstall

    cp -r usr $out
    cp -r sbin $out/

    runHook postInstall
  '';

  # TODO: Fix runtime error
  # Error Loading the library libcpqci.so or libhponcfg.so
  # openat(AT_FDCWD, "/nix/store/90illc73xfs933d06daq6d41njs8yh66-glibc-2.32-37/lib/libcpqci64.so", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
  # openat(AT_FDCWD, "/nix/store/90illc73xfs933d06daq6d41njs8yh66-glibc-2.32-37/lib/libhponcfg64.so", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
  postFixup = ''
    cp $out/lib64/libhponcfg64.so $out/lib64/libhponcfg.so
  '';

  meta = {
    description = "HPE RILOE II/iLO online configuration utility";
    maintainers = with lib.maintainers; [ johnazoidberg ];
    license = lib.licenses.unfree;
    homepage = "https://downloads.linux.hpe.com/SDR/project/mcp/";
    platforms = [ "x86_64-linux" ];
    broken = true;
  };
}
