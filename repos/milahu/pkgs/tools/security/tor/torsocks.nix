{ lib
, stdenv
, fetchFromGitLab
, autoreconfHook
, libcap
}:

stdenv.mkDerivation rec {
  pname = "torsocks";
  version = "2.4.0-unstable-2022-08-09";

  src = fetchFromGitLab {
    domain = "gitlab.torproject.org";
    owner = "tpo";
    repo = "core/torsocks";
    # fix: configure.ac has version 2.3.0
    #rev = "v${version}";
    #hash = "sha256-ocJkoF9LMLC84ukFrm5pzjp/1gaXqDz8lzr9TdG+f88=";
    rev = "305e42c66d0a6a63f38192a02f31956dcbe5e64f";
    hash = "sha256-GWrmWSQQlFN7C6lVrqJXqgGLGjvP42NgzzinH3gcu6k=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  # torsocks.c:237:2: error: use of undeclared identifier 'tsocks_libc_accept4'; did you mean 'tsocks_libc_accept'?
  # https://gitlab.torproject.org/tpo/core/torsocks/-/issues/40005
  patches = lib.optional stdenv.isDarwin
    ./0001-Fix-macros-for-accept4-2.patch;

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
