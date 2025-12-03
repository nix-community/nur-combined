let
  defaultPriority = 5;
  setMeta = newAttrs: drv: drv // { meta = (drv.meta or { }) // newAttrs; };
  setPriority = newPriority: drv: setMeta { priority = newPriority; } drv;
  makeBetterThan = better: worse: setPriority ((worse.meta.priority or defaultPriority) + 5) better;
in
new: old: {
  orca = makeBetterThan old.orca new.kanidm;
  xorg = old.xorg // {
    xorg-server = makeBetterThan old.xorg.xorg-server new.xwayland;
  };
}
