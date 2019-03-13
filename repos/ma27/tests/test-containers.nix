{ lib, node2container, containers, autostartContainers }:

lib.runTests {

  testNode2Container = {
    expr = node2container "hartzfor";
    expected = "hartzfo";
  };

  testContainers = {
    expr =
      let deployment = { a.deployment.targetEnv = "container"; b.deployment.targetEnv = "none"; };
      in
        containers deployment;

    expected = [ "a" ];
  };

  testAutostartConfig = {
    expr = autostartContainers [ "test0" "test1" "longname1" ];
    expected = {
      containers = {
        longnam.autoStart = true;
        test0.autoStart = true;
        test1.autoStart = true;
      };
    };
  };

}
