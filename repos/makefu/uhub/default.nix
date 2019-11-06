{ stdenv, fetchpatch, fetchFromGitHub, cmake, openssl, sqlite, pkgconfig, systemd
, tlsSupport ? false }:

assert tlsSupport -> openssl != null;

stdenv.mkDerivation rec {
  pname = "uhub";
  version = "2019-06-18";

  src = fetchFromGitHub {
    owner = "janvidar";
    repo = "uhub";
    rev = "78a703924064a92cedeb0a5aab5a80d8f77db73e";
    sha256 = "1dqmj08salhbcdlkglbi03hn9jzgmhjqlb0iysafpzrrwi0mca1z";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake sqlite systemd ] ++ stdenv.lib.optional tlsSupport openssl;

  outputs = [ "out"
    "mod_example"
    "mod_welcome"
    "mod_logging"
    "mod_auth_simple"
    "mod_auth_sqlite"
    "mod_chat_history"
    "mod_chat_only"
    "mod_topic"
    "mod_no_guest_downloads"
  ];

  patches = [
    <nixpkgs/pkgs/servers/uhub/plugin-dir.patch>
  ];

  cmakeFlags = ''
    -DSYSTEMD_SUPPORT=ON
    ${if tlsSupport then "-DSSL_SUPPORT=ON" else "-DSSL_SUPPORT=OFF"}
  '';

  meta = with stdenv.lib; {
    description = "High performance peer-to-peer hub for the ADC network";
    homepage = https://www.uhub.org/;
    license = licenses.gpl3;
    maintainers = [ maintainers.ehmry ];
    platforms = platforms.unix;
  };
}
