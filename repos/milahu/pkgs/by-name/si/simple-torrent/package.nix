# FIXME cannot define new methods on non-local type
/*
Running phase: buildPhase
Building subPackage .
# github.com/anacrolix/go-libutp
vendor/github.com/anacrolix/go-libutp/utp.go:29:12: cannot define new methods on non-local type *C.utp_context
vendor/github.com/anacrolix/go-libutp/utp.go:40:12: cannot define new methods on non-local type *C.utp_context
vendor/github.com/anacrolix/go-libutp/callbacks.go:17:10: cannot define new methods on non-local type *C.utp_callback_arguments
vendor/github.com/anacrolix/go-libutp/callbacks.go:25:10: cannot define new methods on non-local type *C.utp_callback_arguments
vendor/github.com/anacrolix/go-libutp/callbacks.go:29:10: cannot define new methods on non-local type *C.utp_callback_arguments
vendor/github.com/anacrolix/go-libutp/callbacks.go:33:10: cannot define new methods on non-local type *C.utp_callback_arguments
vendor/github.com/anacrolix/go-libutp/callbacks.go:37:10: cannot define new methods on non-local type *C.utp_callback_arguments
*/

{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "simple-torrent";
  version = "1.3.9-6f49429";

  src = fetchFromGitHub {
    owner = "boypt";
    repo = "simple-torrent";
    rev = "6f4942933b71106bae00b4f4c94438e3b315fca2";
    hash = "sha256-jQsSgSkLrz3Vbn0McX3hFKvHRMiwF10WH4OJ55DQBhI=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-UyB54aNIIwoIBW/1Xr8y1U4YkMr+GxxUOmWmMuBYzsA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "a self-hosted remote torrent client";
    homepage = "https://github.com/boypt/simple-torrent";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "simple-torrent";
  };
}
