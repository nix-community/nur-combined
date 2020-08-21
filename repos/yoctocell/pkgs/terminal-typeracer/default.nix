{ stdenv
, fetchFromGitLab
, sources
, rustPlatform
, pkg-config
, openssl
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "terminal-typeracer";
  version = "git";

  src = fetchFromGitLab {
    owner = "ttyperacer";
    repo = "terminal-typeracer";
    rev = sources.terminal-typeracer.rev;
    sha256 = sources.terminal-typeracer.sha256;
  };
  
  cargoSha256 = "16zs3rvb76vqafrljzabvylvp0b7jmr23p4r8p1v1z63q6b96kk7";

  buildInputs = [ openssl sqlite ];
  nativeBuildInputs = [ pkg-config ];

  meta = with stdenv.lib; {
    description = "An open source terminal based version of Typeracer written in rust";
    homepage = "https://gitlab.com/ttyperacer/terminal-typeracer";
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.x86_64;
  };
}
