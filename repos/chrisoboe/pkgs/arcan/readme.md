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
