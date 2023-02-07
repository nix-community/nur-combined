# Hosts

They're all named after [characters from the GOAT RPG](https://www.youtube.com/watch?v=xFU2HL-PQNo)

Breaking the use-cases down:

## Aipom

A test getting microvms going - a test utilising ombi, a cheeky fellow

![Aipom](https://archives.bulbagarden.net/media/upload/3/30/Spr_3e_190.png?raw=true)

## Alakazam

Personal workstation; uses an older Xeon processor and Nvidia GPU.

Generally acts as my testing ground before modules get shipped to other hosts where possible;

![Alakazam](https://archives.bulbagarden.net/media/upload/5/50/Spr_2c_065.png?raw=true)

## Cloyster

Work x86 Macbook;

![Cloyster](https://archives.bulbagarden.net/media/upload/c/c0/Spr_2c_091.png?raw=true)

## Dragonite

Personal server; using a modern Ryzen processor and Nvidia GPU.

Currently runs a number of services via docker; managed by Portainer. Future state is the death of these in favour of microvms that utilise tailscale to communicate

![Dragonite](https://archives.bulbagarden.net/media/upload/b/ba/Spr_2c_149.png?raw=true)

## Gastly

Personal laptop; a secondary testing ground when I'm on the move.

![Gastly](https://archives.bulbagarden.net/media/upload/5/59/Spr_2c_092.png?raw=true)

## Igglybuff

A microvm guest that runs dnsmasq and stubby to provide secure DNS to tailscale-internal devices.

![Igglybuff](https://archives.bulbagarden.net/media/upload/e/e7/Spr_2c_174.png?raw=true)

## Jigglypuff

A raspberry pi 3b+ that runs docker + pihole: the primary node for DNS across devices which will eventually run a microvm guest of Igglybuff in order to reduce/remove use of docker.

![Jigglypuff](https://archives.bulbagarden.net/media/upload/f/fc/Spr_2c_039.png?raw=true)

## Ninetales

Work aarch64 Macbook;

![Ninetales](https://archives.bulbagarden.net/media/upload/3/32/Spr_2c_038.png?raw=true)

## Victreebel

Work aarch64 Macbook;

![Victreebel](https://archives.bulbagarden.net/media/upload/3/3f/Spr_2c_071.png?raw=true)

## Wigglytuff

A raspberry pi 4 that acts as a music box over the 3.5mm headphone jack for the home gym.

![Wigglytuff](https://archives.bulbagarden.net/media/upload/5/5a/Spr_2c_040.png?raw=true)

## Zubat

A configuration that is leveraged within WSL settings. Yep, everyone hates Zubat and the feeling
isn't so far from WSL :cry:

![Zubat](https://archives.bulbagarden.net/media/upload/b/be/Spr_4h_041_m.png?raw=true)
