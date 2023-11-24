/*
usually the buster-client app is installed with buster-client-setup
https://github.com/dessant/buster/wiki/Installing-the-client-app

but that copies the binary to ~/.local/opt/buster/buster-client
which is not so pretty

also buster-client-setup requires UI interaction
while buster-client-setup-cli just writes the json file
*/

{ lib
, substituteAll
, runtimeShell
, buster-client
}:

substituteAll {
  name = "buster-client-setup-cli";
  src = ./buster-client-setup-cli.sh;
  dir = "bin";
  isExecutable = true;
  inherit runtimeShell;
  busterClientBin = "${buster-client}/${buster-client.binPath}";
}
