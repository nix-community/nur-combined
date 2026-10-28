{
  lib,
  stdenvNoCC,
  linuxPackages_latest,
  makeLinuxHeaders,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nolibc";

  inherit (linuxPackages_latest.kernel) src version;

  __structuredAttrs = true;
  strictDeps = true;
  postUnpack = ''
    sourceRoot+=/tools/include/nolibc
  '';

  dontBuild = true;

  makeFlags = [ "OUTPUT=$(out)/" ];
  installTargets = [ "headers" ];

  postInstall = ''
    mv "$out/sysroot/include" "$out/include"
    rmdir "$out/sysroot"
    ln -s ${finalAttrs.passthru.linuxHeaders}/include/* -t $out/include
  '';

  passthru = {
    linuxHeaders = makeLinuxHeaders { inherit (finalAttrs) src version; };
    updateScript = null;
  };

  meta = {
    description = "Libc alternative for minimal programs";
    longDescription = ''
      nolibc is an in-kernel, header-only project that implements a useful
      subset of the C standard library and other POSIX/Linux APIs.
    '';
    homepage = "https://github.com/torvalds/linux/blob/master/tools/include/nolibc/nolibc.h";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
