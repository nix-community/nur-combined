{ stdenv, fetchFromGitHub, makeWrapper
, git
}:

stdenv.mkDerivation rec {
  pname = "git-my";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "davidosomething";
    repo = "git-my";
    rev = version;
    sha256 = "0jji5zw25jygj7g4f6f3k0p0s9g37r8iad8pa0s67cxbq2v4sc0v";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    install -Dm755 -t "$out"/bin ./git-my

    wrapProgram "$out"/bin/git-my \
      --prefix PATH : "${stdenv.lib.makeBinPath [ git ]}"
  '';

  meta = let inherit (stdenv) lib; in {
    description =
      "List remote branches if they're merged and/or available locally";
    homepage = "https://github.com/kamranahmedse/git-standup";
    license = lib.licenses.free;
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
    platforms = lib.platforms.all;
  };
}

