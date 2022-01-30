{ stdenv, lib, pkg-config, protobuf, ncurses, zlib, fetchFromGitHub
, makeWrapper, perlPackages, openssl, autoreconfHook, openssh, bash-completion
, withUtempter ? stdenv.isLinux, libutempter }:

stdenv.mkDerivation {
  name = "mosh-ssh-agent-2022-01-30";

  # TODO: incoperate https://github.com/mobile-shell/mosh/pull/1104
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "87a5e0ad1f8d11437c2349a781176d9ee4c83746";
    sha256 = "sha256-ULJSBFaVdjFmMS+kHV2/gM9YTr91mVwIhDOnH2UOViU=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config makeWrapper ];
  buildInputs = [ protobuf ncurses zlib openssl bash-completion ]
    ++ (with perlPackages; [ perl IOTty ])
    ++ lib.optional withUtempter libutempter;

  patches = [
    ./ssh_path.patch
  ];

  configureFlags = [ "--enable-completion" ] ++ lib.optional withUtempter "--with-utempter";

  postPatch = ''
    substituteInPlace scripts/mosh.pl \
        --subst-var-by ssh "${openssh}/bin/ssh"
    substituteInPlace scripts/mosh.pl \
        --subst-var-by mosh-client "$out/bin/mosh-client"
  '';

  postInstall = ''
      wrapProgram $out/bin/mosh --prefix PERL5LIB : $PERL5LIB
  '';

  CXXFLAGS = lib.optionalString stdenv.cc.isClang "-std=c++11";

  meta = with lib; {
    description = "Mosh fork with ssh-agent support";
    homepage = "https://github.com/Mic92/mosh";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
