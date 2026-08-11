{ lib
, stdenv
, fetchFromGitLab
, autoreconfHook
, libcap
}:

stdenv.mkDerivation rec {
  pname = "torsocks";
  version = "2.4.0-unstable-2023-09-20";

  # https://gitlab.torproject.org/tpo/core/torsocks
  src = fetchFromGitLab {
    domain = "gitlab.torproject.org";
    owner = "tpo";
    repo = "core/torsocks";
    #rev = "v${version}";
    # fix: configure.ac has version 2.3.0
    # fix: config-file.c:184:23: warning: implicit declaration of function 'conf_file_set_enable_ipv6'
    rev = "969d782ad3b560448325ff6e9aa29801d6276a3e";
    hash = "sha256-zA693iTFmbNwjElX7u2pZtYMmVwKL8LaZOnh1JQhRAg=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  patches =
    # torsocks.c:237:2: error: use of undeclared identifier 'tsocks_libc_accept4'; did you mean 'tsocks_libc_accept'?
    # https://gitlab.torproject.org/tpo/core/torsocks/-/issues/40005
    lib.optional stdenv.isDarwin ./0001-Fix-macros-for-accept4-2.patch
    ++
    [
      # fix: config-file.c:332:9: warning: '__builtin_strncpy' output truncated before terminating nul copying as many bytes from a string as its length
      ./fix-strncpy-warnings.patch
    ]
  ;

  # https://gitlab.torproject.org/tpo/core/torsocks/-/blob/main/src/bin/torsocks.in
  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace src/bin/torsocks.in \
      --replace \
        'local getcap="$(PATH="$PATH:/usr/sbin:/sbin" command -v getcap)"' \
        'local getcap="${libcap}/bin/getcap"'
  '';

  doInstallCheck = true;
  installCheckTarget = "check-recursive";

  meta = {
    description      = "Wrapper to safely torify applications";
    homepage         = "https://gitlab.torproject.org/tpo/core/torsocks";
    license          = lib.licenses.gpl2;
    platforms        = lib.platforms.unix;
    maintainers      = with lib.maintainers; [ thoughtpolice ];
  };
}
