# durden
## using durden as session

To allow durden to be selected as sessino add durden to ``services.xserver.displayManager.sessionPackages``. E.g. 
```
services.xserver.displayManager.sessionPackages = [ pkgs.nur.repos.chrisoboe.durden ];
```

## Known Problems
* NixOS always executes sessions through xsession-wrapper (a nixos specific script). This is unreleaded to x and also used for wayland-compositors or in our case durden. If ~/.xsession exists, this file will be executed instead of the selected session. This seems to be nixos releated, and not something we could fix here.

## Todo
* Think about how we can properly install arcan appls to nixos. 
  Currently we install durden and arcan more or less seperated, and start arcan with the absolute path of durden.
  => Arcan finds it's own included appls, and arcan finds durden. But arcan won't find any other appl. I'm not sure if that's futureproof
  
  Possible solutions:
    * the arcan nixpkg could propably written in a way, where the user could add other appl-pkgs. The disadvantage here is that the user can't just install appls via nix, but also needs to configure the arcan nixpkg to use them. I think this is the way plugins are often handled. 
    
    * maybe a folder where all appls are symlinked to could be used (like currently with bins) and arcan could be patched to use this folder.
    
* The startscript currently just executes arcan with durden and thats it. Propably some logic should be added for restarting on failures. Maybe we can use the official durden run script as inpiration. 
