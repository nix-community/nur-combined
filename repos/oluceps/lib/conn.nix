node:{
  basePort ? 51800,
}:
let
  nodes = node;
  validateNode =
    name: node:
    if !(node ? id) then
      throw "${name} no id"
    else if !(builtins.isInt node.id) then
      throw "${name}.id must int"
    else
      node;

  cantorPort =
    i: j: basePort:
    let
      a = if i <= j then i else j;
      b = if i <= j then j else i;
      index = (a + b) * (a + b + 1) / 2 + b;
    in
    basePort + index;

  nodeNames = builtins.attrNames nodes;

  genConn =
    name: node:
    let
      connections = builtins.filter (x: x != null) (
        map (
          peerName:
          if peerName != name then
            let
              peerNode = validateNode peerName nodes.${peerName};
              port = cantorPort node.id peerNode.id basePort;
            in
            {
              name = peerName;
              value = port;
            }
          else
            null
        ) nodeNames
      );
    in
    builtins.listToAttrs connections;

in
builtins.mapAttrs (name: node: genConn name (validateNode name node)) nodes
