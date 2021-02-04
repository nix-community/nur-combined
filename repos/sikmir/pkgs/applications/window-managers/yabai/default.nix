{ lib, stdenv, fetchFromGitHub, Cocoa, ScriptingBridge, xxd }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "3.3.6";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    rev = "v${version}";
    sha256 = "0319k35c2rm0hsf0s5qdx4510g2n3nzg42cw1mhxcqrpi63604gg";
  };

  nativeBuildInputs = [ xxd ];

  buildInputs = [ Cocoa ScriptingBridge ];

  postInstall = ''
    install -Dm755 bin/yabai -t $out/bin
    install -Dm644 doc/yabai.1 -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "A tiling window manager for macOS based on binary space partitioning";
    homepage = "https://github.com/koekeishiya/yabai";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.darwin;
    skip.ci = !stdenv.isDarwin;
  };
}
