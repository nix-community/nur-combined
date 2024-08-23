// vim: set shiftwidth=2 :
use log;
use strings;
use os;
use os::exec;

fn do_exec(args: []str) never = {
  let joined = strings::join(" ", args...);
  log::printfln("exec: {}", joined);
  free(joined);

  let cmd = os::exec::cmd(args[0], args[1..]...)!;
  os::exec::exec(&cmd);
};

export fn main() void = {
  let my_name = os::args[0];
  let exec_line = os::args[1..];
  no_new_privs();
  landlock_restrict();
  do_exec(exec_line);
};
