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
  version = "0.8.7-unstable-2024-11-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoffwhittington";
    repo = "meshtastic-matrix-relay";
    rev = "29b2946485174651f43f77978c7bc4dfbe6c91e7";
    hash = "sha256-3+lGa97Nxy/YhKT0lvlApfVvMauNiUfWC2LKjMeARnc=";
  };

  patches = [
    (toFile "config-path.patch" ''
      --- a/config.py
      +++ b/config.py
      @@ -21 +21 @@
      -config_path = os.path.join(get_app_path(), "config.yaml")
      +config_path = os.getenv("CONFIG_PATH")
    '')

    (toFile "debug-filter.patch" ''
      --- a/plugins/debug_plugin.py
      +++ b/plugins/debug_plugin.py
      @@ -10,2 +10,9 @@
           ):
      +        if (
      +            "decoded" in packet
      +            and "portnum" in packet["decoded"]
      +            and packet["decoded"]["portnum"] in ["POSITION_APP", "TELEMETRY_APP"]
      +        ):
      +            return False
      +
               packet = self.strip_raw(packet)
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

    (toFile "message-format.patch" ''
      --- a/matrix_utils.py
      +++ b/matrix_utils.py
      @@ -233 +235,6 @@
      -        full_message = f"{prefix}{text}"
      +        full_message = (
      +            text
      +            if relay_config["meshtastic"]["broadcast_directly"]
      +            and event.sender == relay_config["meshtastic"]["broadcast_directly"]
      +            else f"{prefix}{text}"
      +        )
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -328 +328,2 @@
      -        formatted_message = f"[{longname}/{meshnet_name}]: {text}"
      +        display_name = shortname if longname == sender else f"{longname} ({shortname})"
      +        formatted_message = f"[{display_name}]: {text}"
    '')

    (toFile "message-packet.patch" ''
      --- a/matrix_utils.py
      +++ b/matrix_utils.py
      @@ -2,2 +2,3 @@
       import io
      +import json
       import re
      @@ -129 +130 @@
      -async def matrix_relay(room_id, message, longname, shortname, meshnet_name, portnum):
      +async def matrix_relay(room_id, message, longname, shortname, meshnet_name, portnum, packet):
      @@ -138,2 +139,3 @@
                   "meshtastic_portnum": portnum,
      +            "meshtastic_packet": json.dumps(packet)
               }
      --- a/meshtastic_utils.py
      +++ b/meshtastic_utils.py
      @@ -364,2 +365,3 @@
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
