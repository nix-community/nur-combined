{ writeShellScriptBin }:
# TODO: try and extract the agent from the snap package https://snapcraft.io/oracle-cloud-agent
writeShellScriptBin "oracle-cloud-agent" ''
  echo Hello World
''
