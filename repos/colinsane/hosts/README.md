## directory structure
- by-name/<hostname>: entrypoints for each host
  - populates config specific to the given `hostname`
  - forwards to `common/`
- common/: configuration which applies to all hosts
- modules/: nixpkgs-style modules which may be used by multiple hosts, but configured separately per host.
  - ideally no module here has effect unless `enable`d
    - however, `enable` may default to true
    - and in practice some of these modules surely aren't fully "disableable"
