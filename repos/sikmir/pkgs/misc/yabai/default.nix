{ lib, stdenv, fetchFromGitHub, Cocoa, ScriptingBridge, xxd }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "3.3.7";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    rev = "v${version}";
    sha256 = "1yx4qp4rwk3ncw57yqy9m0nsg1rb62x4y2mj009lbzx0syfvh84s";
  };

  nativeBuildInputs = [ xxd ];

  buildInputs = [ Cocoa ScriptingBridge ];

  postInstall = ''
    install -Dm755 bin/yabai -t $out/bin
    install -Dm644 doc/yabai.1 -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "A tiling window manager for macOS based on binary space partitioning";
    homepage = src.meta.homepage;
    changelog = "${src.meta.homepage}/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.darwin;
    skip.ci = !stdenv.isDarwin;
  };
}
