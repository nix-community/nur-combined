{ writers

  # Dependencies
, python3Packages
}:

writers.writePython3Bin "meshtastic-url" { libraries = with python3Packages; [ meshtastic ]; } ''
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
''
