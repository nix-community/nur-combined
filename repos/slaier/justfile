default: (apply "local" "test")

local goal="switch": (apply "local" goal)

n1 goal="switch": (apply "n1" goal)

apply nodes="local,n1" goal="switch":
  colmena apply --on {{nodes}} {{goal}}

update:
  find . -type f -name update.sh | parallel -j+1 'cd {//} && ./update.sh'
  nix fmt . 2>/dev/null
