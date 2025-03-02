_: prev: {
  maintainers =
    prev.maintainers
    // prev.optionalAttrs (!prev.maintainers ? federicoschonborn) {
      federicoschonborn = {
        name = "Federico Damián Schonborn";
        email = "federicoschonborn@disroot.org";
        matrix = "FedericoDSchonborn:matrix.org";
        github = "FedericoSchonborn";
        githubId = 62166915;
      };
    };
}
