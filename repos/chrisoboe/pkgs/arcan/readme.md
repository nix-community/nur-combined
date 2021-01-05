# arcan
## installation on nixos

* add the arcan pkg
```
environment.systemPackages = with pkgs;[
  nur.repos.chrisoboe.arcan
];
```

* configure arcan to be always executed as root via suid
```
security.wrappers = {
  arcan = {
    source = "${pkgs.nur.repos.chrisoboe.arcan}/bin/arcan";
    owner = "root";
    setuid = true;
  };
};
```

## todo

* arcan shouln't be executed as root, but as an own user with only the nesesary permissions.
* we should add a nixos module for doing the setup via something like ``programs.arcan.enable = true;`` 
  * creating the arcan user with the nessesarcy permissions (/dev/input, /dev/drm)
  * creating the security wrapper so arcan gets always executed with the arcan user
