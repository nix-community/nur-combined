{
  inputs,
  ...
}:

{
  imports = [ "${inputs.self}/system/users/bjorn" ];
  users.users.bjorn = {
    initialHashedPassword = "$6$CtvntR5WmQUG15Lv$/DwGKjr58xTe74yo0gB2o1n4NvB.cN3cZI7Y2u1rCsFPEEAdFqKPwuXN/dV8hnqQqK8MmHd4U9DC8r5o9XdYD.";
    extraGroups = [ "video" ];
  };
}
