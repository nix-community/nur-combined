{
  apple-sdk,
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xpc_set_event_stream_handler";
  version = "4bbfc25b485e444afcca8b9d5492ef0018c03823";

  src = fetchFromGitHub {
    owner = "snosrap";
    repo = "xpc_set_event_stream_handler";
    rev = finalAttrs.version;
    sha256 = "sha256-uEVrPt2VkhaxjHZ3Jl7vpMzLyFJc1TtgKtAUypQte58=";
  };

  buildInputs = [
    apple-sdk
  ];

  env.NIX_CFLAGS_COMPILE = builtins.concatStringsSep " " [
    "-framework"
    "Foundation"
    "-I${apple-sdk.sdkroot}/usr/include"
  ];

  buildCommand = ''
    xcrun --sdk macosx clang -o xpc_set_event_stream_handler $src/xpc_set_event_stream_handler/main.m
    mkdir -p $out/bin
    install -Dm0555 xpc_set_event_stream_handler -t $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Consume a com.apple.iokit.matching event, then run the executable specified in the first parameter";
    homepage = "https://github.com/snosrap/xpc_set_event_stream_handler";
    license = lib.licenses.mit;
    mainProgram = "xpc_set_event_stream_handler";
    maintainers = [ lib.maintainers.wwmoraes ];
    platforms = lib.platforms.darwin;
  };
})
