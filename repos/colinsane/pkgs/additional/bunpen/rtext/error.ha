// vim: set shiftwidth=2 :
use fs;
use log;
use os::exec;
use rt;

export fn check_error(context: str, what: (void | fs::error | os::exec::error | rt::errno)) void = {
  match (what) {
    case let e: fs::error => log::fatalf("{}: {}", context, fs::strerror(e));
    case let e: os::exec::error => log::fatalf("{}: {}", context, os::exec::strerror(e));
    case let e: rt::errno => log::fatalf("{}: {}: {}", context, rt::errname(e), rt::strerror(e));
    case => void;
  };
};

export fn swallow_error(context: str, what: (void | fs::error | os::exec::error | rt::errno)) void = {
  match (what) {
    case let e: fs::error => log::printfln("{}: {}", context, fs::strerror(e));
    case let e: os::exec::error => log::printfln("{}: {}", context, os::exec::strerror(e));
    case let e: rt::errno => log::printfln("{}: {}: {}", context, rt::errname(e), rt::strerror(e));
    case => void;
  };
};

