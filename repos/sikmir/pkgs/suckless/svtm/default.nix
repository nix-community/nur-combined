{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  abduco,
  sthkd,
  libst,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svtm";
  version = "0-unstable-2021-04-28";

  src = fetchFromGitHub {
    owner = "jeremybobbin";
    repo = "svtm";
    rev = "4edb0e561b5a7ceed75050a1b10340fe03f65616";
    hash = "sha256-kqUBBTDcV7XFINNBGRWq5Mf37DIyBy3+2rk+BVBqAPM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    wrapProgram $out/bin/svtm \
      --prefix PATH : ${
        lib.makeBinPath [
          abduco
          sthkd
          libst
        ]
      }:$out/bin
  '';

  meta = {
    description = "Simple Virtual Terminal Manager";
    homepage = "https://github.com/jeremybobbin/svtm";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
})
