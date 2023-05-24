## directory structure
- by-name/<hostname>: configuration which is evaluated _only_ for the given hostname
- common/: configuration which applies to all hosts
- modules/: nixpkgs-style modules which may be used by multiple hosts, but configured separately per host.
    - ideally no module here has effect unless `enable`d
        - however, `enable` may default to true
        - and in practice some of these modules surely aren't fully "disableable"
