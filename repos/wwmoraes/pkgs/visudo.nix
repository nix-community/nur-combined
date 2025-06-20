{
	fetchgit,
	lib,
	stdenv,
	# coreutils,
	...
}:

stdenv.mkDerivation (finalAttrs: {
	pname = "visudo";
	version = "1.9.16p2";

	src = fetchgit {
		url = "https://git.sudo.ws/sudo";
		rev = "refs/tags/v${finalAttrs.version}";
		# hash = lib.fakeHash;
		hash = "sha256-1G6KddRyXbEDZr7PBHXMxgq5moFUXuihYsPXNgSDTNQ=";
	};
	# src = fetchurl {
	# 	url = "https://www.sudo.ws/dist/sudo-${finalAttrs.version}.tar.gz";
	# 	hash = lib.fakeHash;
	# };

	# export MVPROG=${lib.getExe' coreutils "mv"}
	configurePhase = ''
		export MVPROG=/bin/mv
		./configure \
			--without-pam \
			--with-rundir=/var/run/sudo \
			;
	'';

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
		cp plugins/sudoers/.libs/visudo $out/bin/visudo
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
