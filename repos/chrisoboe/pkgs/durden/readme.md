# durden
## using durden as session

To allow durden to be selected as sessino add durden to ``services.xserver.displayManager.sessionPackages``. E.g. 
```
services.xserver.displayManager.sessionPackages = [ pkgs.nur.repos.chrisoboe.durden ];
```

## Known Bugs
* NixOS always executes sessions through xsession-wrapper (a nixos specific script). This is unreleaded to x and also used for wayland-compositors or in our case durden. If ~/.xsession exists, this file will be executed instead of the selected session. 
