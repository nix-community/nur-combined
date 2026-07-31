final: prev: {
  nur = (prev.nur or { }) // {
    repos = (prev.nur.repos or { }) // {
      josh = import ./default.nix { pkgs = final; };
    };
  };
}
