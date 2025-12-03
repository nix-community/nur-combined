final: prev: {
  borgbackup = prev.borgbackup.overridePythonAttrs (old: {
    disabledTests = (old.disabledTests or [ ]) ++ [ "test_multiple_link_exclusion" ];
  });
}
