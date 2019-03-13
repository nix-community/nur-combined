{ lib }: with lib;

rec {
  /*
    The actual container names in are the first 7 letters
    of the node in the deployment by default.
   */
  node2container = substring 0 7;

  /*
    Searches for available containers in the deployment configuration (`resources.machines`)
    and returns all nodes that appear to be container deployments.
   */
  containers = machines: attrNames
    (filterAttrs (_: v: v.deployment.targetEnv == "container") machines);

  /*
    Generate config for all containers to get automatically autostarted.

    Example:
      cs = [ "db0" "db1" ];
      autostartContainers cs
      => { containers.db0.autoStart = true; containers.db1.autoStart = true; }
   */
  autostartContainers = containers: {
    containers = listToAttrs
      (map (n: nameValuePair (node2container n) { autoStart = true; }) containers);
  };
}
