use config;
use errors::ext;
use log;
use os;
use os::exec;
use ps;
use resources;
use rt;
use rt::ext;

fn set_lo_up() (void | os::exec::error | rt::errno) = {
  let caps = rt::ext::capget()?;
  resources::caps_add(&caps.inheritable, rt::ext::cap::NET_ADMIN);
  rt::ext::capset(caps)?;
  errors::ext::swallow("[namespace/net] raise CAP_NET_ADMIN to configure interface", rt::ext::cap_ambient_raise(rt::ext::cap::NET_ADMIN));

  let rc = ps::shellvpe_or_default(
    config::IP,
    "ip",
    [
      "ip",
      "link",
      "set", "lo", "up",
    ],
    os::getenvs(),
  )?;
  log::printfln("[namespace/net] 'ip link set lo up' exited {}", rc.status);
};
