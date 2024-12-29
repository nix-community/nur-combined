// vim: set shiftwidth=2 :

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

export fn caps_add_caps(cs: *rt::ext::caps, cs2: rt::ext::caps) void = {
  *cs |= cs2;
};

export fn caps_contains(cs: rt::ext::caps, cap: rt::ext::cap) bool = {
  return (cs & (1 << cap: u64)) != 0;
};
