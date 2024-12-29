{ lib
, stdenv

  # Dependencies
, python3
}:

let
  inherit (builtins) toFile;

  script = toFile "meshtastic-url" ''
    #!/usr/bin/env python3

    from argparse import ArgumentParser
    from base64 import urlsafe_b64decode
    from meshtastic.protobuf.apponly_pb2 import ChannelSet
    from urllib.parse import urlparse


    def on_inspect(args):
        base64 = args.url.fragment + "==="
        protobuf = urlsafe_b64decode(base64)
        channel_set = ChannelSet.FromString(protobuf)

        print(channel_set)


    argument_parser = ArgumentParser()
    subcommands = argument_parser.add_subparsers(required=True)
    subcommand_inspect = subcommands.add_parser("inspect")
    subcommand_inspect.set_defaults(handler=on_inspect)
    subcommand_inspect.add_argument("url", type=urlparse)
    args = argument_parser.parse_args()

    args.handler(args)
  '';
in
stdenv.mkDerivation {
  pname = "meshtastic-url";
  version = "0-unstable-2024-12-29";

  dontUnpack = true;

  buildInputs = [ (python3.withPackages (p: with p; [ meshtastic ])) ];

  installPhase = ''
    install -D ${script} $out/bin/meshtastic-url
  '';

  meta = {
    description = "View the content of Meshtastic configuration URLs";
    license = lib.licenses.gpl3Only;
    mainProgram = "meshtastic-url";
  };
}
