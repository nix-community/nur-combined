{ fetchFromGitHub
, lib
, python3Packages
, unstableGitUpdater
}:

let
  inherit (builtins) toFile;
  inherit (lib) replaceStrings;
in
python3Packages.buildPythonApplication rec {
  pname = "meshtastic-matrix-relay";
  version = "0.8.8-unstable-2024-11-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoffwhittington";
    repo = "meshtastic-matrix-relay";
    rev = "5f20d2411952c8cdb6859df022e5e20adb4f94e7";
    hash = "sha256-qUbXCJoW+HOKT9edeh7lfMFQn6IudS4CP7qx/cl6Uko=";
  };

  patches = [
    (toFile "config-path.patch" ''
      --- a/config.py
      +++ b/config.py
      @@ -21 +21 @@
      -config_path = os.path.join(get_app_path(), "config.yaml")
      +config_path = os.getenv("CONFIG_PATH")
    '')

    (toFile "debug.patch" ''
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -249,5 +249,6 @@
       
      -    sender = packet.get("fromId", packet.get("from"))
      +    sender = packet.get("fromId") or packet.get("from")
       
           if sender is None:
      +        logger.debug(f"sender is None: {packet}")
               # Sender ID is None. Using 'Unknown' as sender.")
    '')

    (toFile "debug-filter.patch" ''
      --- a/plugins/debug_plugin.py
      +++ b/plugins/debug_plugin.py
      @@ -10,2 +10,14 @@
           ):
      +        if (
      +            "decoded" not in packet
      +            or (packet["toId"] == "^all" and not packet["decoded"]["portnum"] == "TEXT_MESSAGE_APP")
      +        ):
      +            return False
      +        if packet["toId"] and packet["toId"][0] == "!":
      +            from meshtastic_utils import connect_meshtastic
      +            meshtastic_client = connect_meshtastic()
      +            my_node_id = meshtastic_client.getMyNodeInfo()["user"]["id"]
      +            if packet["toId"] != my_node_id:
      +                return False
      +
    '')

    (toFile "destination.patch" ''
      --- a/matrix_utils.py
      +++ b/matrix_utils.py
      @@ -191,2 +193,8 @@
           text = event.body.strip()
      +    destined_pattern = re.compile(r"^@(\^all|![0-9A-Fa-f]+)\s*:?\s*(.+)$")
      +    destined = destined_pattern.match(text)
      +    if not destined:
      +        return
      +    destinationId = destined[1]
      +    text = destined[2]
       
      @@ -226 +234 @@
      -        logger.debug(f"Processing matrix message from [{full_display_name}]: {text}")
      +        logger.debug(f"Processing matrix message from [{full_display_name}] to [{destinationId}]: {text}")
      @@ -285 +299 @@
      -                    text=full_message, channelIndex=meshtastic_channel
      +                    text=full_message, destinationId=destinationId, channelIndex=meshtastic_channel,
    '')

    (toFile "log-format.patch" ''
      --- a/log_utils.py
      +++ b/log_utils.py
      @@ -16 +16 @@
      -            fmt="%(asctime)s %(levelname)s:%(name)s:%(message)s",
      +            fmt="%(levelname)s:%(name)s:%(message)s",
    '')

    (toFile "mention.patch" ''
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -250,2 +250,3 @@
           sender = packet.get("fromId", packet.get("from"))
      +    recipient = packet["toId"]
       
      @@ -351 +353,6 @@
      -        logger.info(f"Relaying Meshtastic message from {longname} to Matrix")
      +        operator_id = relay_config["matrix"]["operator_id"]
      +        my_node_id = interface.getMyNodeInfo()["user"]["id"]
      +        if operator_id and recipient == my_node_id:
      +            formatted_message = f"{operator_id} {formatted_message}"
      +
      +        logger.info(f"Relaying Meshtastic message from {sender} to {recipient} via Matrix")
    '')

    (toFile "message-format.patch" ''
      --- a/matrix_utils.py
      +++ b/matrix_utils.py
      @@ -233 +235,6 @@
      -        full_message = f"{prefix}{text}"
      +        full_message = (
      +            text
      +            if relay_config["matrix"]["operator_id"]
      +            and event.sender == relay_config["matrix"]["operator_id"]
      +            else f"{prefix}{text}"
      +        )
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -329 +329,2 @@
      -        formatted_message = f"[{longname}/{meshnet_name}]: {text}"
      +        display_name = shortname if longname == sender else f"{longname} ({shortname})"
      +        formatted_message = f"[{display_name}]: {text}"
    '')

    (toFile "message-packet.patch" ''
      --- a/matrix_utils.py
      +++ b/matrix_utils.py
      @@ -1,3 +1,5 @@
       import asyncio
      +import base64
       import io
      +import json
       import re
      @@ -129 +131,7 @@
      -async def matrix_relay(room_id, message, longname, shortname, meshnet_name, portnum):
      +async def matrix_relay(room_id, message, longname, shortname, meshnet_name, portnum, packet):
      +    if "decoded" in packet and "payload" in packet["decoded"]:
      +        if isinstance(packet["decoded"]["payload"], bytes):
      +            packet["decoded"]["payload"] = base64.b64encode(
      +                packet["decoded"]["payload"]
      +            ).decode("utf-8")
      +
      @@ -138,2 +146,3 @@
                   "meshtastic_portnum": portnum,
      +            "meshtastic_packet": json.dumps(packet)
               }
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -370,2 +371,3 @@
                               decoded.get("portnum"),
      +                        packet
                           ),
    '')

    (toFile "pep-518.patch" ''
      --- /dev/null
      +++ b/pyproject.toml
      @@ -0,0 +1,22 @@
      +[project]
      +name = "${pname}"
      +version = "${replaceStrings ["-unstable"] ["+unstable"] version}"
      +
      +[project.scripts]
      +${meta.mainProgram} = "main:main_sync"
      +
      +[build-system]
      +requires = ["setuptools"]
      +build-backend = "setuptools.build_meta"
      +
      +[tool.setuptools]
      +packages = ["plugins"]
      +py-modules = [
      +  "config",
      +  "db_utils",
      +  "log_utils",
      +  "main",
      +  "matrix_utils",
      +  "meshtastic_utils",
      +  "plugin_loader",
      +]
      --- a/main.py
      +++ b/main.py
      @@ -148 +148 @@
      -if __name__ == "__main__":
      +def main_sync():
      @@ -152,0 +153,3 @@
      +
      +if __name__ == "__main__":
      +    main_sync()
    '')
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    haversine
    markdown
    matplotlib
    matrix-nio
    meshtastic
    pillow
    py-staticmaps
    requests
    schedule
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Relay between a Matrix room and a Meshtastic radio";
    homepage = "https://github.com/geoffwhittington/meshtastic-matrix-relay";
    license = lib.licenses.mit;
    mainProgram = "meshtastic-matrix-relay";
  };
}
