{
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

  meta = with lib; {
    description = "safely edit the sudoers file";
    homepage = "https://git.sudo.ws/sudo";
    license = with licenses; [
      sudo
      bsd2
      bsd3
      zlib
    ];
    mainProgram = "visudo";
    maintainers = with maintainers; [ wwmoraes ];
    platforms = platforms.unix;
  };
})
