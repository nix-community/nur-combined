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
  pname = "mqtt-protobuf-to-json";
  version = "0-unstable-2024-12-20";

  src = fetchFromGitHub {
    owner = "pdxlocations";
    repo = "mqtt-protobuf-to-json";
    rev = "d284b2757a230c4f427d3f13f2772070a66f8ee7";
    hash = "sha256-dEERdO7NLoA+S60o1WrFzGtSyjC2lqeY+5hWHQIvMco=";
  };

  pyproject = true;

  patches = [
    (toFile "pep-518.patch" ''
      --- /dev/null
      +++ b/pyproject.toml
      @@ -0,0 +1,16 @@
      +[project]
      +name = "${pname}"
      +version = "${replaceStrings ["-unstable"] ["+unstable"] version}"
      +
      +[project.scripts]
      +${meta.mainProgram} = "main:main"
      +
      +[build-system]
      +requires = ["setuptools"]
      +build-backend = "setuptools.build_meta"
      +
      +[tool.setuptools]
      +py-modules = [
      +  "encryption",
      +  "main",
      +]
    '')

    (toFile "log-level.patch" ''
      --- a/main.py
      +++ b/main.py
      @@ -13 +13 @@
      -    level=logging.INFO,  # Adjust level as needed (DEBUG for more detailed output)
      +    level=os.getenv("LOG_LEVEL", "INFO"),  # Adjust level as needed (DEBUG for more detailed output)
    '')

    (toFile "config-path.patch" ''
      --- a/main.py
      +++ b/main.py
      @@ -22 +22 @@
      -config_path = os.path.join(script_dir, 'config.json')
      +config_path = os.getenv("CONFIG_PATH")
    '')

    (toFile "conditional-publish.patch" ''
      --- a/main.py
      +++ b/main.py
      @@ -191,4 +191,5 @@
               # Publish message to the JSON topic
      -        publish_topic = json_topic + "/" + channel_name + "/" + msg.topic.split('/')[-1]
      -        client.publish(publish_topic, json_message)
      +        if json_topic:
      +            publish_topic = json_topic + "/" + channel_name + "/" + msg.topic.split('/')[-1]
      +            client.publish(publish_topic, json_message)
    '')
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    cryptography
    meshtastic
    paho-mqtt_2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Relay Meshtastic packets from an MQTT protobuf topic to an MQTT JSON topic";
    homepage = "https://github.com/pdxlocations/mqtt-protobuf-to-json";
    license = lib.licenses.unfree; # No license
    mainProgram = "mqtt-protobuf-to-json";
  };
}
