final: prev: {
  borgbackup = prev.borgbackup.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [
      "test_multiple_link_exclusion"
      # need inode flags (chattr +d) on the build dir
      "test_basic_functionality"
      "test_file_status_excluded"
    ];
  });
}
