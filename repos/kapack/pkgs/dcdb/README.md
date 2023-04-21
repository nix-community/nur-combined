# Notes on the packaging of DCDB (by a poor intern) :

## What works

As of the time of writing this file, I used the dcdbpusher and collectagent executables in my experiments. I configured the dcdbpusher to collect procfs and sysfs related metrics and it works. 

## What doesn't (or rather what I couldn't get to work)

Metrics from perfevent do not work.

## What remains unknown 

All the analysis tools, the graphana dashboard, the scripts as well as the init.d and systemd services are not tested for now. I do not know if they are even correctly installed.

## Be careful with

Be weary of the configuration folder. The sample configuration folder included in the git repo is copied in the nix store destination folder. Nevertheless, the dcdbpusher configuration requires a path to the dcdb library. This means that if you happen to copy the folder in the nix store or write the configuration file yourself, YOU SHOULD PUT THE CORRESPONDING NIX STORE PATH in the plugins/plugin/path parameter. 
To have the path you could do : ```nix eval --raw .#dcdb```
Don't forget to add /lib at the end of the path.

