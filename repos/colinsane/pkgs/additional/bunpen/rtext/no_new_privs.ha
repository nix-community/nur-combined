// vim: set shiftwidth=2 :
use rt;

export fn no_new_privs() (rt::errno | int) = {
  return rt::prctl(rt::PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
};
