{ linkFarm
, geoclue2
}:
linkFarm "where-am-i" [{
  # bring the `where-am-i` tool into a `bin/` directory so it can be invokable via PATH
  name = "bin/where-am-i";
  path = "${geoclue2}/libexec/geoclue-2.0/demos/where-am-i";
}]

