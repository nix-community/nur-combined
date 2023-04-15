{...}: {
  perSystem = {
    self',
    config,
    ...
  }: {
    formatter = config.treefmt.build.wrapper;
  };
}
