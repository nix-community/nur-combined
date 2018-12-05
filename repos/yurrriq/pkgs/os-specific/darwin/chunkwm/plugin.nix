{ cfg, stdenv, fetchFromGitHub
, Carbon, Cocoa, ApplicationServices
, imagemagick ? null }:

let

  repoOwner = cfg.owner or "koekeishiya";

  repoName = cfg.repo or "chunkwm";

in

stdenv.mkDerivation rec {
  name = "chunkwm-${cfg.name}-${cfg.version}";
  version = "${cfg.version}";

  src = fetchFromGitHub {
    inherit (cfg) sha256;
    owner = repoOwner;
    repo = repoName;
    rev = "v${cfg.version}";
  };

buildInputs = [ Carbon Cocoa ApplicationServices ] ++ [ imagemagick ];

  buildPhase = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -F/System/Library/Frameworks"
    substituteInPlace src/plugins/${cfg.name}/makefile \
        --replace "clang++" "/usr/bin/clang++"
  '';

  installPhase = ''
    cd src/plugins/${cfg.name} && make all
    mkdir -p $out/bin/chunkwm-plugins/
    cp ../../../plugins/${cfg.name}.so $out/bin/chunkwm-plugins/
  '';

  meta = with stdenv.lib; {
    description = "A ChunkWM plugin for ${cfg.name}";
    inherit (src.meta) homepage;
    downloadPage = "${src.meta.homepage}/releases";
    maintainers = with maintainers; [ peel yurrriq ];
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
