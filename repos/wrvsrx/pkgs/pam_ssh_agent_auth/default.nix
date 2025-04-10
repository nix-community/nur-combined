{ pam_ssh_agent_auth }:
pam_ssh_agent_auth.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # remove need of root
    ./remove_root_need.patch
  ];
})
