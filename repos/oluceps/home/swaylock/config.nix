{ pkgs, ... }:
let
  img = pkgs.fetchurl {
    url = "https://s3.nyaw.xyz/misskey//54f23f73-cd56-49ac-abf2-3c4ab3409c5a.jpg";
    name = "54f23f73-cd56-49ac-abf2-3c4ab3409c5a";
    hash = "sha256-AlQEyfi5f1cavux0advHDMQBfue14NPQhiXPUFpo/Bs=";
  };
in
''
  daemonize
  font=Hanken Grotesk
  image=${img}
  indicator-radius=100
  indicator-thickness=15
  inside-clear-color=563F2E00
  inside-color=00000000
  inside-ver-color=563F2E00
  inside-wrong-color=563F2E00
  key-hl-color=FFFFFB
  ring-clear-color=86A697
  ring-color=86A697
  ring-ver-color=FEDFE1
  ring-wrong-color=F17C67
  scaling=fill
  show-failed-attempts
  text-clear-color=FCFAF2
  text-ver-color=FEDFE1
  text-wrong-color=F17C67
''
