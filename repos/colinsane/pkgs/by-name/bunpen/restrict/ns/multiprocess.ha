// vim: set shiftwidth=2 :
//
// helpers for handling multi-processing,
// e.g. parent-child relations
use errors;
use errors::ext;
use log;
use os;
use os::exec;
use rt;
use rt::ext;
use unix::signal;

// fork and:
// - in the child: continue execution as normal
// - in the parent: wait for the child, then propagate its exit status.
//                  forward any signals, including SIGKILL, to the child.
fn fork_and_propagate() (void | os::exec::error | rt::errno) = {
  let outer_pid = rt::getpid();
  return match (fork_and_die_with_parent()?) {
    case let child_pid: os::exec::process => yield wait_and_propagate(child_pid);
    case =>
      log::println("[namespace/fork] continuing as child");
  };
};

// fork, but configured so that the child receives SIGKILL upon the parent's exit,
// ensuring that the child may never outlive the parent.
fn fork_and_die_with_parent() (os::exec::process | void | os::exec::error | rt::errno) = {
  let outer_pid = rt::getpid();
  return match (os::exec::fork()?) {
    case let child_pid: os::exec::process => yield child_pid;
    case =>
      log::println("[namespace/fork] child: configuring parent death signal");
      // configure that when the parent dies, we receive SIGTERM.
      // this ensures that the parent process behaves transparently;
      // when someone `kill`s the sandbox wrapper, it will properly kill the
      // actual sandboxed application.
      //
      // in the normal mode of operation (when used with `wait_and_propagate`),
      // SIGKILL is not sent. rather, the parent will receive SIGTERM, SIGHUP,
      // etc, in `wait_and_propagate`, forward that to the child, the child
      // gracefully exits, and the parent forwards the exit status.
      // SIGKILL is sent to the child only when the parent exits without waiting
      // for the child, likely because it was killed by SIGKILL, itself.
      rt::prctl(rt::PR_SET_PDEATHSIG, rt::SIGKILL: u64, 0, 0, 0)?;
      let parent_pid = rt::getppid();
      if (parent_pid != outer_pid && !(parent_pid == 0 && rt::getpid() == 1)) {
        // ppid=0 only when we fork a new PID namespace, where this child is the new PID 1
        log::printfln("[namespace/fork] expected parent pid={} after forking but got {} instead", outer_pid: int, parent_pid: int);
        // the parent exited between the `fork` and `prctl` operations
        return errors::cancelled;
      };
      log::println("[namespace/fork] child: configured");
  };
};

fn wait_and_propagate(child_pid: os::exec::process) (void | os::exec::error) = {
  forward_signals(child_pid);
  log::println("[namespace/fork] signals configured");
  let status = wait_child(child_pid)?;
  let rc = rt::wexitstatus(status.status);
  // TODO: if the child exited due to a signal (e.g. SIGTERM), we (confusingly?) exit 0.
  // seems correct behavior may be to send the same termination signal to ourselves.
  log::printfln("[namespace/fork] child {} exited with {}; forwarding as {}", child_pid: int, status.status, rc);
  os::exit(rc);  // propagate exit code
};

// run the provided command in a new process, and wait for its return.
// under the hood:
// 1. fork
// 2. in child: execvpe
// 3. in parent: wait for child
export fn shellvpe(name: str, argv: []str, envp: []str = []) (os::exec::status | os::exec::error | rt::errno) = {
  return match (fork_and_die_with_parent()?) {
    case void =>
      errors::ext::check("shellvpe", rt::ext::execvpe(name, argv, envp));
      assert(false, "unreachable");
      return os::exec::status { ... };
    case let child_pid: os::exec::process =>
      yield wait_child(child_pid);
  };
};

// same as `shellvpe(name, argv, envp)` but fallback to `name=default` if `name`
// isn't found on PATH
export fn shellvpe_or_default(default: str, name: str, argv: []str, envp: []str = []) (os::exec::status | os::exec::error | rt::errno) = {
  return match (fork_and_die_with_parent()?) {
    case void =>
      errors::ext::check("shellvpe", rt::ext::execvpe_or_default(default, name, argv, envp));
      assert(false, "unreachable");
      return os::exec::status { ... };
    case let child_pid: os::exec::process =>
      yield wait_child(child_pid);
  };
};

// fn wait_child(child_pid: os::exec::process) (os::exec::status | os::exec::error) = {
//   for (true) {
//     match (os::exec::wait(&child_pid)) {
//       case let e: os::exec::error => match (e) {
//         case errors::interrupted =>
//           // i guess before the days of `poll`, `wait` had to wait on either the
//           // child OR a signal sent to this pid; so we need to retry if the
//           // reason we woke isn't because the child died...
//           void;
//         case => return e;
//       };
//       case let status: os::exec::status => return status;
//     };
//   };
// };

// block until the provided child exits, and then return its exit status.
// this function actually waits on *any* child, in a loop, but only returns the
// exit code for the specific child of interest.
// this way, we're able to act as a child reaper (as expected of PID 1).
fn wait_child(child_pid: os::exec::process) (os::exec::status | os::exec::error) = {
  for (true) {
    match (os::exec::waitany()) {
      case let e: os::exec::error => match (e) {
        case errors::interrupted =>
          // i guess before the days of `poll`, `wait` had to wait on either the
          // child OR a signal sent to this pid; so we need to retry if the
          // reason we woke isn't because the child died...
          log::printfln("[namespace/fork] waitany() interrupted (signal?)... will retry");
        case => return e;
      };
      case let proc_and_status: (os::exec::process, os::exec::status) => {
        let (proc, status) = proc_and_status;
        if (proc == child_pid) {
          return status;
        };
        // else we've just reaped a zombie child which had forked away from the
        // main program
      };
    };
  };
};

const SIGNALS_TO_FORWARD = [
  unix::signal::sig::HUP,
  unix::signal::sig::INT,  // Ctrl+C
  unix::signal::sig::QUIT,  // Ctrl+\
  // unix::signal::sig::ILL,
  // unix::signal::sig::TRAP
  unix::signal::sig::ABRT,
  // unix::signal::sig::BUS,
  // unix::signal::sig::FPE,
  // unix::signal::sig::KILL (can't be caught or ignored)
  unix::signal::sig::USR1,
  // unix::signal::sig::SEGV,
  unix::signal::sig::USR2,
  // unix::signal::sig::PIPE,
  // unix::signal::sig::ALRM,
  unix::signal::sig::TERM,
  // unix::signal::sig::STKFLT,
  // unix::signal::sig::CHLD
  // unix::signal::sig::CONT,
  // unix::signal::sig::STOP (can't be caught or ignored)
  // unix::signal::sig::TSTP,  // Ctrl+Z
  unix::signal::sig::TTIN,  // ??
  unix::signal::sig::TTOU,  // ??
  unix::signal::sig::URG,
  unix::signal::sig::XCPU,
  unix::signal::sig::XFSZ,
  // unix::signal::sig::VTALRM,
  // unix::signal::sig::PROF,
  unix::signal::sig::WINCH,  // terminal resized
  unix::signal::sig::IO,
  unix::signal::sig::POLL,
  unix::signal::sig::PWR,
  // unix::signal::sig::SYS,  // illegal syscall argument
];

// there's no apparent way to pass state into a signal handler,
// except via process globals
let g_child: os::exec::process = 0;

// configure signal handlers so that any signal we receive is forwarded to the child.
// this is important for systems which use signals for communication,
// e.g. `kill -SIGUSR2 $(pidof wvkbd)` will toggle an on-screen-keyboard, but only if delivered.
fn forward_signals(child: os::exec::process) void = {
  g_child = child;
  for (let sig .. SIGNALS_TO_FORWARD) {
    unix::signal::handle(sig, &forward_signal_handler);
  };
  // posix real-time extensions defines an additional set of general-purpose
  // signals for users. things like `wvkbd` use these (SIGRTMIN)
  for (let sig = 32; sig <= 64; sig +=1) {
    unix::signal::handle(sig: unix::signal::sig, &forward_signal_handler);
  };
};

fn forward_signal_handler(sig: unix::signal::sig, info: *unix::signal::siginfo, ucontext: *opaque) void = {
  log::printfln("[namespace] forward signal {} to child {}", sig: int, g_child: int);
  // TODO: maybe we shouldn't swallow all errors; if the child somehow died, and
  // the signal is undeliverable, then abort?
  errors::ext::swallow(
    "[namespace] forward child signal {}",
    os::exec::sig(g_child, sig),
    sig: int,
  );
};

