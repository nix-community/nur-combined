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

fn caps_contains(cs: rt::ext::caps, cap: rt::ext::cap) bool = {
  return (cs & (1 << cap: u64)) != 0;
};

export fn capability_restrict(what: *resources) void = {
  //// for clarity, `needed_now` and `needed` are *specifically* what we need at
  //// this point. however this code is not required, because we have something
  //// akin to E=CAPS_ALL, P=CAPS_ALL, I=CAPS_NONE just from entering the namespace.
  // let needed = what.caps;
  // caps_add(&needed, rt::ext::cap::SETPCAP);
  // let needed_now = rt::ext::CAPS_NONE;
  // caps_add(&needed_now, rt::ext::cap::SETPCAP);
  // errors::ext::check("[capability] capset early", rt::ext::capset(
  //   needed_now,  // effective
  //   needed,  // permitted
  //   needed,  // inherited
  // ));

  // drop unneeded caps from the bounding set before anything else.
  // specifically, CAP_SETPCAP is required to *drop* caps from B;
  // CAP_SETPCAP is implicitly granted after namespace creation (?), but we'll
  // likely lose it once we switch to the desired privileges.
  //
  // dropping a privilege from the B set seems to *not* remove it from E/I/P/Amb.
  for (let cap = rt::ext::CAP_FIRST; cap <= rt::ext::CAP_LAST; cap += 1) {
    if (!caps_contains(what.caps, cap)) {
      let cap_str = rt::ext::cap_tostring(cap);
      log::printfln("[capability/restrict] lowering {}", cap_str);
      // `swallow` when raising caps but `check` when lowering because messing
      // up the latter means running with too many privs.
      errors::ext::check(
        "[capability] drop ambient {}",
        rt::ext::cap_ambient_lower(cap),
        cap_str,
      );
      errors::ext::check(
        "[capability] drop bounding {}",
        rt::ext::capbset_drop(cap),
        cap_str,
      );
    };
  };

  // set I/P precisely as asked, and drop everything from E since we don't need it anymore.
  // as long as a cap is both I and P, we can add it to Amb, at which point it
  // will become E at the moment we `exec` into the wrapped program.
  errors::ext::check("[capability] capset", rt::ext::capset(
    0,  // effective
    what.caps,  // permitted
    what.caps,  // inherited
  ));

  for (let cap = rt::ext::CAP_FIRST; cap <= rt::ext::CAP_LAST; cap += 1) {
    if (caps_contains(what.caps, cap)) {
      let cap_str = rt::ext::cap_tostring(cap);
      log::printfln("[capability/restrict] raising {}", cap_str);
      errors::ext::swallow(
        "[capability] raise ambient {}",
        rt::ext::cap_ambient_raise(cap),
        cap_str,
      );
    };
  };

  log::println("capability restrictions activated");
};
