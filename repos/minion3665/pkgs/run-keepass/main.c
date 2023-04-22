#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <sys/param.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <grp.h>

static int   orig_ngroups = -1;
static gid_t orig_gid = -1;
static uid_t orig_uid = -1;
static gid_t orig_groups[NGROUPS_MAX];
   
void spc_drop_privileges(int permanent) {
  gid_t newgid = getgid(  ), oldgid = getegid(  );
  uid_t newuid = getuid(  ), olduid = geteuid(  );
   
  if (!permanent) {
    /* Save information about the privileges that are being dropped so that they
     * can be restored later.
     */
    orig_gid = oldgid;
    orig_uid = olduid;
    orig_ngroups = getgroups(NGROUPS_MAX, orig_groups);
  }
   
  /* If root privileges are to be dropped, be sure to pare down the ancillary
   * groups for the process before doing anything else because the setgroups(  )
   * system call requires root privileges.  Drop ancillary groups regardless of
   * whether privileges are being dropped temporarily or permanently.
   */
  if (!olduid) setgroups(1, &newgid);
   
  if (newgid != oldgid) {
#if !defined(linux)
    setegid(newgid);
    if (permanent && setgid(newgid) =  = -1) abort(  );
#else
    if (setregid((permanent ? newgid : -1), newgid) == -1) abort(  );
#endif
  }
   
  if (newuid != olduid) {
#if !defined(linux)
    seteuid(newuid);
    if (permanent && setuid(newuid) =  = -1) abort(  );
#else
    if (setreuid((permanent ? newuid : -1), newuid) == -1) abort(  );
#endif
  }
   
  /* verify that the changes were successful */
  if (permanent) {
    if (newgid != oldgid && (setegid(oldgid) != -1 || getegid(  ) != newgid))
      abort(  );
    if (newuid != olduid && (seteuid(olduid) != -1 || geteuid(  ) != newuid))
      abort(  );
  } else {
    if (newgid != oldgid && getegid(  ) != newgid) abort(  );
    if (newuid != olduid && geteuid(  ) != newuid) abort(  );
  }
}
   
void spc_restore_privileges(void) {
  if (geteuid(  ) != orig_uid)
    if (seteuid(orig_uid) == -1 || geteuid(  ) != orig_uid) abort(  );
  if (getegid(  ) != orig_gid)
    if (setegid(orig_gid) == -1 || getegid(  ) != orig_gid) abort(  );
  if (!orig_uid)
    setgroups(orig_ngroups, orig_groups);
}

int main(int argc, char *argv[])
{
  freopen("/run/secrets/keepassPassword", "r", stdin);
  spc_drop_privileges(1);
  system("keepassxc --pw-stdin ~/Sync/KeePass\\ Vaults/Passwords.kdbx");
}

