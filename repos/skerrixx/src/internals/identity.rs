//! username and hostname, a drop-in slice of the `whoami` crate.
//!
//! mirrors `whoami` on linux: username comes from the passwd entry for the
//! effective uid (via `getpwuid_r`), hostname from `gethostname(2)`. fallbacks
//! match `whoami::username()` ("unknown") and
//! `whoami::fallible::hostname().unwrap_or_default()` ("") respectively.

use std::os::raw::c_char;

/// the login name for the effective uid, or "unknown" if we can't get it.
/// same as `whoami::username()`.
pub fn username() -> String {
    let mut pwd: libc::passwd = unsafe { std::mem::zeroed() };
    let mut result: *mut libc::passwd = std::ptr::null_mut();
    let mut buf = vec![0u8; 16_384]; // size from the getpwuid_r man page

    // SAFETY: getpwuid_r writes into `pwd` and the `buf` scratch space; both
    // live for the whole call and `result` is a valid out-pointer.
    let rc = unsafe {
        libc::getpwuid_r(
            libc::geteuid(),
            &mut pwd,
            buf.as_mut_ptr() as *mut c_char,
            buf.len(),
            &mut result,
        )
    };

    if rc == 0 && !result.is_null() && !pwd.pw_name.is_null() {
        // SAFETY: on success pw_name points into our `buf`, still alive here.
        let name = unsafe { std::ffi::CStr::from_ptr(pwd.pw_name) };
        return name.to_string_lossy().into_owned();
    }

    "unknown".to_string()
}

/// the system hostname, or "" if we can't get it.
/// same as `whoami::fallible::hostname().unwrap_or_default()`.
pub fn hostname() -> String {
    // max hostname length is 255 bytes, plus room for a nul.
    let mut buf = vec![0u8; 256];

    // SAFETY: `buf` is writable for `buf.len()` bytes and alive across the
    // call. gethostname writes at most `len` bytes (no terminator on truncate).
    let rc = unsafe { libc::gethostname(buf.as_mut_ptr() as *mut c_char, buf.len()) };
    if rc != 0 {
        return String::new();
    }

    let end = buf.iter().position(|&b| b == 0).unwrap_or(buf.len());
    String::from_utf8_lossy(&buf[..end]).into_owned()
}
