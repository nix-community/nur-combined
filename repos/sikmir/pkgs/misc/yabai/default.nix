{ lib, stdenv, fetchFromGitHub, Carbon, Cocoa, SkyLight, ScriptingBridge, installShellFiles, xxd }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "3.3.10";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-8O6//T894C32Pba3F2Z84Z6VWeCXlwml3xsXoIZGqL0";
  };

  nativeBuildInputs = [ installShellFiles xxd ];

  buildInputs = [ Carbon Cocoa SkyLight ScriptingBridge ];

  postInstall = ''
    install -Dm755 bin/yabai -t $out/bin
    installManPage doc/yabai.1
  '';

  meta = with lib; {
    description = "A tiling window manager for macOS based on binary space partitioning";
    inherit (src.meta) homepage;
    changelog = "${src.meta.homepage}/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.darwin;
    skip.ci = true; # Failed on Big Sur (11)
  };
}
