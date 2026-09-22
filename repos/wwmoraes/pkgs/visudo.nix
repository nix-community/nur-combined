{
  buildPackages,
  fetchgit,
  lib,
  stdenv,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "visudo";
  version = "1.9.16p2";

  src = fetchgit {
    url = "https://git.sudo.ws/sudo";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-1G6KddRyXbEDZr7PBHXMxgq5moFUXuihYsPXNgSDTNQ=";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  prePatch = ''
    # do not set sticky bit in nix store
    substituteInPlace src/Makefile.in --replace 04755 0755
  '';

  configureFlags = [
    "--with-rundir=/run/sudo"
    "--without-sendmail"
    "--without-pam"
    "--enable-static-sudoers"
    "--disable-shared-libutil"
  ];

  MVPROG = "/bin/mv";
  CFLAGS = [
    "-DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
  ];

  buildPhase = ''
    make -C lib/util
    make -C lib/iolog
    make -C lib/eventlog
    make -C lib/logsrv
    make -C lib/protobuf-c

    make -C plugins/sudoers
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp plugins/sudoers/visudo $out/bin/visudo
  '';

  meta = {
    description = "safely edit the sudoers file";
    homepage = "https://git.sudo.ws/sudo";
    # TODO drop sudo license (since it is removed upstream on 26.05) and use the new AND function
    # See https://github.com/NixOS/nixpkgs/blob/4747f6e35a68279aa2d44bc19e55deeb40fe3598/pkgs/by-name/su/sudo/package.nix#L108-L117
    # From https://www.sudo.ws/about/license/
    license = {
      licenseType = "compound";
      operator = "AND";
      licenses =
        with lib.licenses;
        lib.flatten [
          isc
          bsd2
          bsd3
          zlib
          (lib.optional (lib.licenses ? sudo) sudo)
          (lib.optional (lib.licenses ? bsdAskToEndorse) bsdAskToEndorse)
        ];
    };
    mainProgram = "visudo";
    maintainers = with lib.maintainers; [ wwmoraes ];
    platforms = lib.platforms.unix;
  };
})
