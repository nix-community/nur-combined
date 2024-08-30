// vim: set shiftwidth=2 :

use errors::ext;
use log;
use rt::ext;

export fn cap_array_to_caps(cap_arr: []rt::ext::cap) rt::ext::caps = {
  let cs: rt::ext::caps = 0;
  for (let cap .. cap_arr)
    caps_add(&cs, cap);
  return cs;
};

export fn caps_add(cs: *rt::ext::caps, cap: rt::ext::cap) void = {
  *cs |= (1 << cap: u64);
};

export fn capability_restrict(what: *resources) void = {
  // TODO: call PR_CAP_AMBIENT and PR_CAPBSET_DROP
  errors::ext::check("capability", rt::ext::capset(
    what.caps,  // effective
    what.caps,  // permitted
    what.caps,  // inherited
  ));
  log::println("capability restrictions activated");
};
