//! Path spelling rules as a value, so the Windows ones can be tested anywhere.
//!
//! `std::path` splits and compares by the HOST's rules, which left every
//! Windows-only path rule unreachable from a test that does not run on Windows:
//! on macOS `c:\a\b` is a single `Component`, so the Windows branch of a
//! relativisation could not be exercised at all. #146 lived in exactly that
//! blind spot — two relativisations compared a lowercased canonical key against
//! a mixed-case `current_dir()`, matched nothing past the drive letter, and
//! quietly printed absolute paths in every diagnostic instead.
//!
//! dart's `path` package models this as `Style.posix` / `Style.windows` on an
//! explicit `Context`, which is how its own suite checks Windows behaviour on a
//! POSIX host. This is the same idea, narrowed to the one operation sasso
//! needs: the relative path from one absolute path to another.

/// Which platform's rules a path is read and written by.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub(crate) enum Style {
    /// `/` separates, and two names differing in case are two files.
    Posix,
    /// `\` separates for output and `/` is read as one too; two names differing
    /// in ASCII case are ONE file, and a drive letter belongs to the root
    /// rather than being a segment.
    Windows,
}

/// The rules of the platform this build runs on.
pub(crate) const HOST: Style = if cfg!(windows) {
    Style::Windows
} else {
    Style::Posix
};

impl Style {
    /// The separator to spell a path WITH. Windows reads `/` as a separator too
    /// (see [`Style::is_sep`]), but dart writes `\` there, so a diagnostic path
    /// does.
    pub(crate) fn sep(self) -> &'static str {
        match self {
            Style::Posix => "/",
            Style::Windows => "\\",
        }
    }

    /// Whether `c` separates two segments.
    fn is_sep(self, c: char) -> bool {
        c == '/' || (self == Style::Windows && c == '\\')
    }

    /// The byte length of `p`'s absolute root — `0` when `p` is relative.
    ///
    /// Windows has four spellings: a drive (`C:\`), a UNC share
    /// (`\\server\share\`), the current drive's root (`\`), and a verbatim or
    /// device wrapper around a drive (`\\?\C:\`, `\\.\C:\`) — which
    /// `std::fs::canonicalize` produces and `current_dir` never does.
    fn root_len(self, p: &str) -> usize {
        if self == Style::Posix {
            return usize::from(p.starts_with('/'));
        }
        let skip = if p.starts_with(r"\\?\") || p.starts_with(r"\\.\") {
            4
        } else {
            0
        };
        let rest = &p[skip..];
        let b = rest.as_bytes();
        // A drive letter is a root only with a separator after it. `C:foo` is
        // DRIVE-RELATIVE — the current directory on C:, which a process tracks
        // per drive — so it has no root at all and nothing can be measured
        // from it.
        if b.len() >= 2 && b[0].is_ascii_alphabetic() && b[1] == b':' {
            let sep = b.get(2).is_some_and(|&c| self.is_sep(c as char));
            return if sep { skip + 3 } else { 0 };
        }
        // A UNC share: two separators, a server, a separator, a share. The
        // share is part of the root — `\\a\b` and `\\a\c` share no directory.
        if skip == 0 && b.len() >= 2 && self.is_sep(b[0] as char) && self.is_sep(b[1] as char) {
            let mut end = 2;
            for _ in 0..2 {
                end += rest[end..].find(|c| self.is_sep(c)).unwrap_or(rest.len() - end);
                if end < rest.len() {
                    end += 1;
                }
            }
            return end;
        }
        // The current drive's root.
        usize::from(b.first().is_some_and(|&c| self.is_sep(c as char)))
    }

    /// `p`'s absolute root, or `None` when `p` is relative.
    fn root(self, p: &str) -> Option<&str> {
        let n = self.root_len(p);
        (n > 0).then(|| &p[..n])
    }

    /// `p`'s non-empty segments, with its root and any repeated separators
    /// dropped.
    pub(crate) fn segments<'a>(self, p: &'a str) -> impl Iterator<Item = &'a str> + 'a {
        p[self.root_len(p)..]
            .split(move |c| self.is_sep(c))
            .filter(|s| !s.is_empty())
    }

    /// Whether two absolute roots name the same one. On Windows a drive letter
    /// is case-insensitive, `/` and `\` are the same separator, and a verbatim
    /// or device marker is not part of the identity: `std::fs::canonicalize`
    /// emits one where `current_dir` does not, so the two sides of a comparison
    /// routinely disagree about it.
    ///
    /// A trailing separator is not part of the identity either: a share is
    /// spelled `\\server\share` when it is the whole path and
    /// `\\server\share\` when something follows, so the two sides of a
    /// comparison disagree about it whenever the working directory IS the
    /// share.
    ///
    /// The verbatim UNC form (`\\?\UNC\server\share`) is NOT unwrapped —
    /// nothing here produces it.
    fn roots_eq(self, a: &str, b: &str) -> bool {
        if self == Style::Posix {
            return a == b;
        }
        fn bare(style: Style, r: &str) -> &str {
            let r = match r.strip_prefix(r"\\?\").or_else(|| r.strip_prefix(r"\\.\")) {
                // Only a drive root survives the unwrap: see the note above.
                Some(inner) if style.root_len(inner) == inner.len() => inner,
                _ => r,
            };
            // `> 0` keeps the current drive's root, which is nothing BUT a
            // separator, from being trimmed away to the empty string.
            match r.char_indices().next_back() {
                Some((i, c)) if i > 0 && style.is_sep(c) => &r[..i],
                _ => r,
            }
        }
        self.same(bare(self, a), bare(self, b))
    }

    /// Whether two segments (or two roots) name the same thing.
    ///
    /// The Windows fold is ASCII-only, matching dart's `Style.windows`
    /// comparison. That is deliberately narrower than the full-Unicode
    /// `to_lowercase()` that `importer::absolute_normalized` applies to a
    /// canonical key, so a path with a non-ASCII uppercase letter does not
    /// relativise and is displayed absolute — which is what dart does with it
    /// too, out of the same mismatch between its `canonicalizePart` and its
    /// comparison.
    fn same(self, a: &str, b: &str) -> bool {
        if self == Style::Posix {
            return a == b;
        }
        let mut x = a.chars();
        let mut y = b.chars();
        loop {
            match (x.next(), y.next()) {
                (None, None) => return true,
                (Some(p), Some(q)) => {
                    let alike = p.eq_ignore_ascii_case(&q) || (self.is_sep(p) && self.is_sep(q));
                    if !alike {
                        return false;
                    }
                }
                _ => return false,
            }
        }
    }
}

/// The segments of the relative path from directory `base` to `target`, or
/// `None` when there is no relative spelling at all: one of the two is not
/// absolute, or their roots differ (`D:\x` from `C:\y`, `\\a\b` from `\\a\c`).
///
/// Callers join with whatever separator their OUTPUT wants — `/` for a
/// source-map URL on every platform, [`Style::sep`] for a diagnostic path —
/// which is why this hands back the pieces rather than a string.
pub(crate) fn relative_parts<'a>(style: Style, base: &str, target: &'a str) -> Option<Vec<&'a str>> {
    if !style.roots_eq(style.root(base)?, style.root(target)?) {
        return None;
    }
    let base: Vec<&str> = style.segments(base).collect();
    let target: Vec<&str> = style.segments(target).collect();
    let common = base
        .iter()
        .copied()
        .zip(target.iter().copied())
        .take_while(|&(a, b)| style.same(a, b))
        .count();
    let mut parts = vec![".."; base.len() - common];
    parts.extend_from_slice(&target[common..]);
    Some(parts)
}

/// dart's `p.prettyUri` for a filesystem path: `abs` spelled relative to the
/// directory `cwd`, unless that would take more segments than `abs` itself (a
/// file far outside the tree reads better as itself than as a stack of `..`).
///
/// Both arguments must already be absolute and lexically normalized — this
/// decides a SPELLING, it does not resolve `.` or `..`. dart renders every
/// stack frame through it, the entry stylesheet's included (#151), which is
/// why it lives here rather than beside one caller.
pub(crate) fn pretty(style: Style, abs: &str, cwd: &str) -> String {
    let Some(parts) = relative_parts(style, cwd, abs) else {
        // No relative spelling exists — a different drive or share, or a
        // current directory that is not absolute. dart's `p.relative` hands
        // the target back unchanged there.
        return abs.to_string();
    };
    // dart keeps the relative spelling only while it is no longer, in segments,
    // than the absolute one; its `p.split` counts the root (`/`, `C:\`,
    // `\\server\share`) as one segment, which `segments` excludes.
    if parts.len() > 1 + style.segments(abs).count() {
        return abs.to_string();
    }
    if parts.is_empty() {
        // `abs` IS `cwd`: dart's `p.relative(x, from: x)` is `.`, and one
        // segment never loses the comparison above.
        return ".".to_string();
    }
    parts.join(style.sep())
}

/// The filesystem path a `file://` URL names, or `None` for anything else —
/// a `data:` URL, a custom importer's key, a bare path.
///
/// Only the shapes a stylesheet URL actually takes are handled, and the rest
/// are declined rather than guessed at. `file:///a/b` is `/a/b`;
/// `file://localhost/a/b` is the same file spelled the long way (RFC 8089, and
/// the importer's own decoder in `napi` accepts it, so a frame must too);
/// `file://server/share/a` is a UNC path under [`Style::Windows`] and nothing
/// under [`Style::Posix`], which has no spelling for it. Percent escapes are
/// decoded, because a directory called `my docs` arrives as `my%20docs` and a
/// frame that said so would name a file nobody has.
pub(crate) fn file_url_path(style: Style, url: &str) -> Option<String> {
    // LOSSY, because this one produces a path to SHOW: a frame naming a
    // file with an undecodable byte in it is still better than no frame.
    // Whoever is about to OPEN the path wants the strict half instead —
    // `crate::file_url_to_path`.
    Some(String::from_utf8_lossy(&file_url_bytes(style, url)?).into_owned())
}

/// The bytes a `file:` URL names: percent-decoding done, and nothing about
/// UTF-8 decided.
///
/// This is the half that kept drifting. `napi/src/lib.rs` had its own copy
/// of it, and the two had already disagreed twice:
///
///   file://localhost/a   napi accepted it, this one declined   (fixed #161)
///   file:///a%FFb        this one decoded lossily, napi refused
///
/// The first was a bug in one copy. The second is not — they want
/// different answers, because one produces a path to SHOW and the other
/// one to READ. So the structure lives here once (the `file://` prefix,
/// the empty and `localhost` authorities, a drive letter arriving as
/// `/C:/`, a UNC authority, which separator comes out) and the UTF-8
/// policy is stated at each edge instead of copied with the rest.
pub(crate) fn file_url_bytes(style: Style, url: &str) -> Option<Vec<u8>> {
    let rest = url.strip_prefix("file://")?;
    // The `localhost` authority means the local machine, exactly as the empty
    // one does. Keep the slash that introduces the path.
    let rest = rest
        .strip_prefix("localhost/")
        .map_or(rest, |p| &rest[rest.len() - p.len() - 1..]);
    // `file:///a` (empty authority, the usual spelling) vs `file://host/share`.
    let sep = |mut b: Vec<u8>| {
        if style == Style::Windows {
            for c in &mut b {
                if *c == b'/' {
                    *c = b'\\';
                }
            }
        }
        b
    };
    let bytes = if let Some(local) = rest.strip_prefix('/') {
        let decoded = percent_decode_bytes(local);
        match style {
            // A drive letter arrives as `/C:/a`, and the leading slash is the
            // URL's, not the path's.
            Style::Windows if is_drive_start_bytes(&decoded) => sep(decoded),
            Style::Windows => {
                let mut out = vec![b'\\'];
                out.extend(sep(decoded));
                out
            }
            Style::Posix => {
                let mut out = vec![b'/'];
                out.extend(decoded);
                out
            }
        }
    } else if rest.is_empty() {
        return None;
    } else {
        // An authority. Only Windows can spell it.
        if style == Style::Posix {
            return None;
        }
        let mut out = vec![b'\\', b'\\'];
        out.extend(sep(percent_decode_bytes(rest)));
        out
    };
    Some(bytes)
}

/// Whether `name` begins with a URL scheme.
///
/// A scheme of ONE letter is read as a Windows drive instead (`C:\a`), which
/// is the rule dart's `package:path` and every browser use; without it every
/// Windows path would look like a URL. `data:` has no `//`, so looking for
/// one is not enough.
fn has_scheme(name: &str) -> bool {
    let Some(colon) = name.find(':') else { return false };
    if colon < 2 {
        return false;
    }
    let mut chars = name[..colon].chars();
    chars.next().is_some_and(|c| c.is_ascii_alphabetic())
        && chars.all(|c| c.is_ascii_alphanumeric() || matches!(c, '+' | '-' | '.'))
}

/// Whether `p` starts with a drive letter (`C:` or `C:/`).
fn is_drive_start_bytes(p: &[u8]) -> bool {
    matches!(p, [c, b':', ..] if c.is_ascii_alphabetic()) || matches!(p, [c, b':'] if c.is_ascii_alphabetic())
}

fn is_drive_start(p: &str) -> bool {
    let b = p.as_bytes();
    b.len() >= 2 && b[0].is_ascii_alphabetic() && b[1] == b':'
}

/// `%XX` escapes decoded, everything else left alone. A stray `%` that is not
/// followed by two hex digits is a literal `%`, which is what browsers and
/// dart's `Uri.toFilePath` both do.
fn percent_decode(s: &str) -> String {
    String::from_utf8_lossy(&percent_decode_bytes(s)).into_owned()
}

/// [`percent_decode`] without deciding what the bytes mean.
fn percent_decode_bytes(s: &str) -> Vec<u8> {
    if !s.contains('%') {
        return s.as_bytes().to_vec();
    }
    let b = s.as_bytes();
    let mut out = Vec::with_capacity(b.len());
    let mut i = 0;
    while i < b.len() {
        let hex = |c: u8| (c as char).to_digit(16);
        match (
            b.get(i),
            b.get(i + 1).copied().and_then(hex),
            b.get(i + 2).copied().and_then(hex),
        ) {
            (Some(b'%'), Some(hi), Some(lo)) => {
                out.push((hi * 16 + lo) as u8);
                i += 3;
            }
            _ => {
                out.push(b[i]);
                i += 1;
            }
        }
    }
    out
}

/// How a stack frame names a file, given whatever the compiler was handed:
/// a path or a `file://` URL, absolute or not.
///
/// The two front ends arrive here with different spellings of the same thing —
/// the binary passes paths, the JS API passes `file://` URLs because its
/// importer bridge resolves relative `@use` against them — and dart shows both
/// as a path relative to the working directory. `cwd` is `None` when the
/// process has no readable one, which for `wasm32-unknown-unknown` is always:
/// there is no `getcwd` to call, so the host has to say.
///
/// Returns `None` unless `name` names a file ABSOLUTELY — a `data:` URL, a
/// custom importer's key, and a name that is already relative all keep
/// whatever rule the caller has for them. A relative key in particular must
/// not be mistaken for a path: a custom importer's `virtual/foo.scss` shows
/// as `foo.scss`, and handing it back whole would be a different frame.
pub(crate) fn pretty_name(style: Style, name: &str, cwd: Option<&str>) -> Option<String> {
    let abs = match file_url_path(style, name) {
        Some(p) => p,
        None if has_scheme(name) => return None, // an importer's URL, not a file
        None => name.to_string(),
    };
    if style.root_len(&abs) == 0 {
        return None;
    }
    Some(match cwd {
        Some(cwd) => pretty(style, &abs, cwd),
        None => abs,
    })
}

/// Which platform's rules to read a diagnostic name by.
///
/// [`HOST`] is decided when the binary is COMPILED, and one build runs
/// somewhere it cannot describe: the wasm module is `wasm32-unknown-unknown`,
/// so `HOST` is always `Posix` there — including on Windows node, where the
/// host hands it `C:\work` and `file:///C:/work/a.scss`. Reading those by
/// POSIX rules leaves `/C:/work/a.scss` in the frame, which is neither the
/// path nor what the addon on the same machine prints.
///
/// So the spelling decides, and `HOST` is the answer only when nothing in the
/// data says otherwise. A POSIX working directory never begins with a drive
/// letter or a UNC root, so this cannot change what a native build does.
pub(crate) fn style_for(cwd: Option<&str>, name: &str) -> Style {
    let windows_shaped = |s: &str| {
        // An authority that is not the local machine is a UNC share, and only
        // Windows has a spelling for one — so such a URL says which platform
        // it came from even when nothing else does. Without this the no-cwd
        // fallback declined `file://server/share/a.scss` and printed it.
        if let Some(auth) = s.strip_prefix("file://") {
            if !auth.is_empty()
                && !auth.starts_with('/')
                && auth != "localhost"
                && !auth.starts_with("localhost/")
            {
                return true;
            }
        }
        // Decoded first, because `file_url_path` decodes and these two have
        // to agree: `file:///C%3A/work/a.scss` is a drive, and reading it
        // raw makes it a POSIX path called `C%3A`.
        let decoded;
        let s = match s.strip_prefix("file:///") {
            Some(rest) => {
                decoded = percent_decode(rest);
                decoded.as_str()
            }
            None => s,
        };
        // A drive letter or a UNC root. NOT a lone leading backslash: a POSIX
        // file name may contain one, and `process.cwd()` on Windows is always
        // drive-rooted, so nothing is lost by declining the ambiguous case.
        is_drive_start(s) || s.starts_with(r"\\")
    };
    match cwd {
        Some(c) if windows_shaped(c) => Style::Windows,
        Some(_) => HOST,
        None if windows_shaped(name) => Style::Windows,
        None => HOST,
    }
}

#[cfg(test)]
mod tests {
    use super::{file_url_path, has_scheme, pretty, pretty_name, relative_parts, style_for, Style, HOST};

    /// Joined with the style's own separator, which is what a diagnostic path
    /// uses. `None` is "no relative spelling exists".
    fn rel(style: Style, base: &str, target: &str) -> Option<String> {
        relative_parts(style, base, target).map(|p| p.join(style.sep()))
    }

    /// #146, verbatim from the first Windows CI run: `FsImporter`'s canonical
    /// key is lowercased (dart's `p.canonicalize` for `Style.windows`) while
    /// `current_dir()` keeps the filesystem's spelling. Compared literally, the
    /// two match only as far as the drive letter and every loaded file is shown
    /// as an absolute temp path.
    #[test]
    fn windows_relativises_a_lowercased_key_against_a_mixed_case_cwd() {
        assert_eq!(
            rel(
                Style::Windows,
                r"C:\Users\RUNNER~1\AppData\Local\Temp\sasso_frames",
                r"c:\users\runner~1\appdata\local\temp\sasso_frames\src\sub\_warnme.scss",
            )
            .as_deref(),
            Some(r"src\sub\_warnme.scss")
        );
    }

    /// The same spelling difference is a real difference on POSIX, where two
    /// cases are two files.
    #[test]
    fn posix_case_is_significant() {
        assert_eq!(
            rel(Style::Posix, "/Users/me/app", "/users/me/app/src/a.scss").as_deref(),
            Some("../../../users/me/app/src/a.scss")
        );
        assert_eq!(
            rel(Style::Posix, "/Users/me/app", "/Users/me/app/src/a.scss").as_deref(),
            Some("src/a.scss")
        );
    }

    /// Windows reads `/` as a separator, so a path spelled either way splits
    /// and compares the same.
    #[test]
    fn windows_accepts_either_separator() {
        assert_eq!(
            rel(Style::Windows, r"C:\dev\app", "C:/dev/app/src/a.scss").as_deref(),
            Some(r"src\a.scss")
        );
    }

    /// A `..` chain when the target is not under the base, and the mixed case
    /// that produced #146 on the way out of the tree as well as into it.
    #[test]
    fn walks_up_out_of_the_base() {
        assert_eq!(
            rel(Style::Windows, r"C:\Dev\App\out", r"c:\dev\app\src\a.scss").as_deref(),
            Some(r"..\src\a.scss")
        );
        assert_eq!(
            rel(Style::Posix, "/dev/app/out", "/dev/other/a.scss").as_deref(),
            Some("../../other/a.scss")
        );
    }

    /// Different roots have no relative spelling: a `..` chain across drives
    /// would name nothing at all. Callers fall back to the absolute path.
    #[test]
    fn different_roots_have_no_relative_spelling() {
        assert_eq!(rel(Style::Windows, r"C:\dev\app", r"D:\dev\app\src\a.scss"), None);
        assert_eq!(
            rel(Style::Windows, r"\\nas\share\app", r"\\nas\other\app\a.scss"),
            None
        );
        // One side relative: there is no common root to measure from.
        assert_eq!(rel(Style::Windows, "dev", r"C:\dev\a.scss"), None);
        assert_eq!(rel(Style::Posix, "/dev", "dev/a.scss"), None);
    }

    /// A UNC share is the root, not two leading segments, and it folds case
    /// like any other Windows name.
    #[test]
    fn unc_share_is_the_root() {
        assert_eq!(
            rel(Style::Windows, r"\\NAS\Share\app", r"\\nas\share\app\src\a.scss").as_deref(),
            Some(r"src\a.scss")
        );
        assert_eq!(
            rel(
                Style::Windows,
                r"\\nas\share\app\out",
                r"\\nas\share\app\src\a.scss"
            )
            .as_deref(),
            Some(r"..\src\a.scss")
        );
    }

    /// A drive letter without a separator after it is DRIVE-RELATIVE: `C:foo`
    /// means "foo in whatever directory this process is in on C:", which is
    /// not something a relative path can be measured from or to.
    #[test]
    fn a_drive_without_a_separator_is_not_a_root() {
        assert_eq!(rel(Style::Windows, r"C:\dev\app", "C:foo"), None);
        assert_eq!(rel(Style::Windows, "C:foo", r"C:\dev\app\a.scss"), None);
        // Both drive-relative: still nothing to measure, even though the two
        // spellings share a drive letter.
        assert_eq!(rel(Style::Windows, "C:foo", "C:bar"), None);
        // The drive alone is the same case.
        assert_eq!(rel(Style::Windows, "C:", r"C:\a.scss"), None);
    }

    /// A share is spelled `\\server\share` when it is the whole path and
    /// `\\server\share\` when something follows it, so a working directory
    /// that IS the share used to match nothing under it.
    #[test]
    fn a_root_matches_with_or_without_its_trailing_separator() {
        assert_eq!(
            rel(Style::Windows, r"\\nas\share", r"\\nas\share\app\a.scss").as_deref(),
            Some(r"app\a.scss")
        );
        assert_eq!(
            rel(Style::Windows, r"\\nas\share\", r"\\nas\share\app\a.scss").as_deref(),
            Some(r"app\a.scss")
        );
        // A different share still does not match, trailing separator or not.
        assert_eq!(rel(Style::Windows, r"\\nas\share", r"\\nas\other\a.scss"), None);
    }

    /// `std::fs::canonicalize` returns a verbatim path and `current_dir` does
    /// not, so one side of a comparison can carry a `\\?\` the other lacks.
    #[test]
    fn a_verbatim_prefix_is_not_part_of_the_root_identity() {
        assert_eq!(
            rel(Style::Windows, r"\\?\C:\dev\app", r"C:\dev\app\src\a.scss").as_deref(),
            Some(r"src\a.scss")
        );
        assert_eq!(
            rel(Style::Windows, r"C:\dev\app", r"\\?\c:\dev\app\src\a.scss").as_deref(),
            Some(r"src\a.scss")
        );
    }

    /// Repeated separators and a trailing one are not empty segments.
    #[test]
    fn empty_segments_are_dropped() {
        assert_eq!(
            rel(Style::Windows, r"C:\dev\app\", r"C:\dev\\app\src\a.scss").as_deref(),
            Some(r"src\a.scss")
        );
        assert_eq!(
            rel(Style::Posix, "/dev/app/", "/dev/app//src/a.scss").as_deref(),
            Some("src/a.scss")
        );
    }

    /// The root itself: dart counts it as one segment when it splits a path,
    /// which is what `segments` deliberately does not include.
    #[test]
    fn segments_exclude_the_root() {
        assert_eq!(
            Style::Windows.segments(r"C:\dev\app\a.scss").collect::<Vec<_>>(),
            ["dev", "app", "a.scss"]
        );
        assert_eq!(
            Style::Windows.segments(r"\\nas\share\a.scss").collect::<Vec<_>>(),
            ["a.scss"]
        );
        assert_eq!(
            Style::Windows.segments(r"\\?\C:\dev\a.scss").collect::<Vec<_>>(),
            ["dev", "a.scss"]
        );
        assert_eq!(
            Style::Posix.segments("/dev/a.scss").collect::<Vec<_>>(),
            ["dev", "a.scss"]
        );
        assert_eq!(
            Style::Posix.segments("dev/a.scss").collect::<Vec<_>>(),
            ["dev", "a.scss"]
        );
    }

    /// The Windows fold is ASCII-only, as dart's is — and the canonical key it
    /// is compared against was lowercased with full Unicode rules, so a
    /// non-ASCII uppercase letter anywhere in the path defeats relativisation
    /// on both implementations alike.
    #[test]
    fn the_windows_fold_is_ascii_only() {
        assert_eq!(
            rel(Style::Windows, r"C:\dev\ÄRGER", r"c:\dev\ärger\a.scss").as_deref(),
            Some(r"..\ärger\a.scss"),
            "the non-ASCII segment does not fold, so the walk leaves the directory"
        );
    }

    /// #146, as the first Windows CI run reported it: the canonical key is
    /// lowercased and the working directory is not, and the display used to
    /// fall all the way through to the absolute temp path.
    #[test]
    fn a_loaded_file_under_a_mixed_case_windows_cwd_is_relative() {
        assert_eq!(
            pretty(
                Style::Windows,
                r"c:\users\runner~1\appdata\local\temp\sasso_frames\src\sub\_warnme.scss",
                r"C:\Users\RUNNER~1\AppData\Local\Temp\sasso_frames",
            ),
            r"src\sub\_warnme.scss"
        );
    }

    /// dart writes the relative spelling in the platform's style, so a frame is
    /// `\`-separated on Windows and `/`-separated everywhere else — and that is
    /// true of the entry stylesheet's frame too, however it was typed on the
    /// command line (#151).
    #[test]
    fn the_separator_is_the_platforms() {
        assert_eq!(
            pretty(Style::Posix, "/dev/app/src/sub/a.scss", "/dev/app"),
            "src/sub/a.scss"
        );
        assert_eq!(
            pretty(Style::Windows, r"C:\dev\app\src\sub\a.scss", r"C:\dev\app"),
            r"src\sub\a.scss"
        );
    }

    /// dart's `p.prettyUri` prefers the ABSOLUTE path once the relative one
    /// would have more segments — a file far outside the tree reads better as
    /// itself than as a stack of `..`. The root counts as one segment, so a
    /// path one level out of the tree is a tie and the relative form wins it.
    #[test]
    fn a_file_far_outside_the_tree_stays_absolute() {
        // 5 `..` + 2 segments = 7 against 1 + 2 = 3: absolute.
        assert_eq!(
            pretty(
                Style::Posix,
                "/tmp/scratch/a.scss",
                "/dev/app/deep/deeper/deepest"
            ),
            "/tmp/scratch/a.scss"
        );
        // 1 `..` + 2 segments = 3 against 1 + 3 = 4: relative.
        assert_eq!(
            pretty(Style::Posix, "/dev/src/a.scss", "/dev/app"),
            "../src/a.scss"
        );
    }

    /// A different drive has no relative spelling, so it is shown as it is
    /// rather than as a `..` chain that would resolve somewhere else entirely.
    #[test]
    fn another_drive_is_shown_absolute() {
        assert_eq!(
            pretty(Style::Windows, r"D:\lib\a.scss", r"C:\dev\app"),
            r"D:\lib\a.scss"
        );
    }

    /// dart's `p.relative(x, from: x)` is `.`, not the empty string — which is
    /// what joining no segments at all would produce.
    #[test]
    fn a_path_that_is_the_working_directory_is_a_dot() {
        assert_eq!(pretty(Style::Posix, "/dev/app", "/dev/app"), ".");
        assert_eq!(pretty(Style::Windows, r"C:\dev\app", r"c:\dev\app"), ".");
        // The root itself, where there are no segments on either side.
        assert_eq!(pretty(Style::Posix, "/", "/"), ".");
    }

    /// A `file://` URL is what the JS API hands the compiler, because its
    /// importer bridge resolves relative `@use` against it. Every frame it
    /// appears in used to print it verbatim, scheme and all.
    #[test]
    fn a_file_url_names_the_path_it_points_at() {
        assert_eq!(
            file_url_path(Style::Posix, "file:///a/b/c.scss").as_deref(),
            Some("/a/b/c.scss")
        );
        assert_eq!(
            file_url_path(Style::Windows, "file:///C:/a/b.scss").as_deref(),
            Some(r"C:\a\b.scss")
        );
        // A UNC share has no POSIX spelling, so POSIX declines rather than
        // inventing one.
        assert_eq!(
            file_url_path(Style::Windows, "file://server/share/a.scss").as_deref(),
            Some(r"\\server\share\a.scss")
        );
        assert_eq!(file_url_path(Style::Posix, "file://server/share/a.scss"), None);
        // Not a file URL at all.
        assert_eq!(file_url_path(Style::Posix, "data:;base64,YQ=="), None);
        assert_eq!(file_url_path(Style::Posix, "/a/b.scss"), None);
        // `localhost` is this machine, exactly as the empty authority is.
        // The napi copy of this decoder accepted it while this one did not,
        // which is how an entry spelled that way was read happily and then
        // printed as a URL in the frame (#161, #163).
        assert_eq!(
            file_url_path(Style::Posix, "file://localhost/a/b.scss").as_deref(),
            Some("/a/b.scss")
        );
        assert_eq!(
            file_url_path(Style::Windows, "file://localhost/C:/a.scss").as_deref(),
            Some(r"C:\a.scss")
        );
        // Nothing after the authority is not a path.
        assert_eq!(file_url_path(Style::Posix, "file://"), None);
    }

    /// What this decoder hands back is ROOTED, in either style.
    ///
    /// The napi bridge asks "is this usable as a filesystem base" and used
    /// to answer by looking for a leading `/` — which reads `C:\a` and
    /// `\\server\share` as relative, so on Windows a `file:///C:/…`
    /// containing URL resolved nothing and every relative `@use` fell
    /// through to the load paths. It asks the host now (#163).
    ///
    /// The host check itself cannot be exercised off its host. This can:
    /// it pins the half that decides the answer, which is that the decoder
    /// produces something each style calls rooted.
    #[test]
    fn what_it_decodes_is_rooted_in_its_own_style() {
        for (style, url) in [
            (Style::Posix, "file:///a/b.scss"),
            (Style::Posix, "file://localhost/a/b.scss"),
            (Style::Windows, "file:///C:/a/b.scss"),
            (Style::Windows, "file://localhost/C:/a.scss"),
            (Style::Windows, "file://server/share/a.scss"),
        ] {
            let p = file_url_path(style, url).expect("decodes");
            assert!(
                style.root_len(&p) > 0,
                "{url:?} decoded to {p:?}, which {style:?} does not call rooted",
            );
        }
    }

    /// A directory with a space arrives percent-encoded. A frame naming
    /// `my%20docs` names a file nobody has.
    #[test]
    fn percent_escapes_are_decoded() {
        assert_eq!(
            file_url_path(Style::Posix, "file:///my%20docs/a%2Bb.scss").as_deref(),
            Some("/my docs/a+b.scss"),
        );
        // A stray `%` is a literal one, as `Uri.toFilePath` treats it.
        assert_eq!(
            file_url_path(Style::Posix, "file:///100%/a.scss").as_deref(),
            Some("/100%/a.scss")
        );
        // Multi-byte UTF-8 survives being split across escapes.
        assert_eq!(
            file_url_path(Style::Posix, "file:///%E6%A8%A3/a.scss").as_deref(),
            Some("/樣/a.scss")
        );
    }

    /// The whole point: both front ends' spellings of one file produce the
    /// same frame. The binary passes a path, the JS API passes a URL.
    #[test]
    fn both_front_ends_name_a_file_the_same_way() {
        let cwd = "/work/proj";
        assert_eq!(
            pretty_name(Style::Posix, "file:///work/proj/src/a.scss", Some(cwd)).as_deref(),
            Some("src/a.scss"),
        );
        assert_eq!(
            pretty_name(Style::Posix, "/work/proj/src/a.scss", Some(cwd)).as_deref(),
            Some("src/a.scss"),
        );
        // And on Windows, where the drive letter is the root.
        assert_eq!(
            pretty_name(
                Style::Windows,
                "file:///C:/work/proj/src/a.scss",
                Some(r"C:\work\proj")
            )
            .as_deref(),
            Some(r"src\a.scss"),
        );
    }

    /// `wasm32-unknown-unknown` has no `getcwd`, so the host may have nothing
    /// to offer. An absolute path is better than a URL even unrelativised.
    #[test]
    fn without_a_cwd_it_is_still_a_path_not_a_url() {
        assert_eq!(
            pretty_name(Style::Posix, "file:///work/proj/src/a.scss", None).as_deref(),
            Some("/work/proj/src/a.scss"),
        );
    }

    /// Only a name that is absolute is ours to respell. A relative one is
    /// either already the spelling the caller wanted (the binary hands one
    /// over pre-made) or a custom importer's key, and a name carrying another
    /// scheme belongs to an importer outright.
    ///
    /// The first version of this asserted that a relative name came back
    /// UNCHANGED — the same string a caller gets by declining, so it read as
    /// correct while hiding the difference that matters to
    /// `module_diag_url`, whose rule for a relative key is its LAST SEGMENT.
    /// The test codified the bug.
    #[test]
    fn only_an_absolute_name_is_ours_to_respell() {
        assert_eq!(pretty_name(Style::Posix, "src/a.scss", Some("/work")), None);
        assert_eq!(
            pretty_name(Style::Posix, "data:;base64,YQ==", Some("/work")),
            None
        );
        assert_eq!(pretty_name(Style::Posix, "npm:foo/bar.scss", Some("/work")), None);
        assert_eq!(
            pretty_name(Style::Posix, "/work/src/a.scss", Some("/work")).as_deref(),
            Some("src/a.scss"),
        );
    }

    /// A one-letter "scheme" is a Windows drive. Read the other way, every
    /// Windows path is a URL and no frame on Windows names a file.
    #[test]
    fn a_drive_letter_is_not_a_scheme() {
        assert!(!has_scheme(r"C:\work\a.scss"));
        assert!(!has_scheme("C:/work/a.scss"));
        assert!(has_scheme("data:;base64,YQ=="));
        assert!(has_scheme("file:///a"));
        assert!(has_scheme("npm:foo"));
        assert_eq!(
            pretty_name(Style::Windows, r"C:\work\proj\src\a.scss", Some(r"C:\work\proj")).as_deref(),
            Some(r"src\a.scss"),
        );
    }

    /// dart keeps the absolute spelling once the relative one costs more
    /// segments — `pretty` already does this, and a URL must not escape it.
    #[test]
    fn a_url_far_outside_the_tree_stays_absolute() {
        let far = pretty_name(Style::Posix, "file:///a.scss", Some("/work/proj/deep/deeper"));
        assert_eq!(far.as_deref(), Some("/a.scss"));
        assert_eq!(
            pretty(Style::Posix, "/a.scss", "/work/proj/deep/deeper"),
            "/a.scss"
        );
    }

    /// `file://localhost/a` is the same file as `file:///a` (RFC 8089), and
    /// the importer's own decoder in `napi` already accepts it — so a frame
    /// that declined it printed the URL for a file the compiler had happily
    /// read.
    #[test]
    fn the_localhost_authority_is_the_local_machine() {
        assert_eq!(
            file_url_path(Style::Posix, "file://localhost/a/b.scss").as_deref(),
            Some("/a/b.scss"),
        );
        assert_eq!(
            file_url_path(Style::Windows, "file://localhost/C:/a/b.scss").as_deref(),
            Some(r"C:\a\b.scss"),
        );
        assert_eq!(
            pretty_name(
                Style::Posix,
                "file://localhost/work/proj/src/a.scss",
                Some("/work/proj")
            )
            .as_deref(),
            Some("src/a.scss"),
        );
        // Any OTHER authority is still a UNC share, or nothing.
        assert_eq!(file_url_path(Style::Posix, "file://server/share/a.scss"), None);
    }

    /// A custom importer's canonical key can be relative and is not a path.
    /// `module_diag_url` shows its last segment; answering with the whole key
    /// would quietly change every such frame.
    #[test]
    fn a_relative_key_is_not_a_path_to_relativise() {
        assert_eq!(pretty_name(Style::Posix, "virtual/foo.scss", Some("/work")), None);
        assert_eq!(pretty_name(Style::Posix, "foo.scss", Some("/work")), None);
        assert_eq!(
            pretty_name(Style::Windows, r"virtual\foo.scss", Some(r"C:\work")),
            None
        );
        // An absolute one still answers.
        assert!(pretty_name(Style::Posix, "/work/virtual/foo.scss", Some("/work")).is_some());
    }

    /// The wasm module is `wasm32-unknown-unknown`, so `HOST` is `Posix` in it
    /// even when it is running on Windows node — where the host hands it
    /// `C:\work` and `file:///C:/work/a.scss`. Read by POSIX rules those come
    /// out as `/C:/work/a.scss`, which is neither the path nor what the addon
    /// on the same machine prints.
    #[test]
    fn the_spelling_decides_the_style_not_the_build() {
        assert_eq!(
            style_for(Some(r"C:\work\proj"), "file:///C:/work/proj/a.scss"),
            Style::Windows
        );
        assert_eq!(
            style_for(Some(r"\\server\share"), "file://server/share/a.scss"),
            Style::Windows
        );
        // Whatever this build is, a POSIX working directory is read as POSIX.
        assert_eq!(style_for(Some("/work/proj"), "file:///work/proj/a.scss"), HOST);
        // With no cwd the name is all there is to go on.
        assert_eq!(style_for(None, "file:///C:/work/a.scss"), Style::Windows);
        assert_eq!(style_for(None, "file:///work/a.scss"), HOST);

        // The whole point, spelled out: the Windows answer, from a build whose
        // HOST is POSIX.
        assert_eq!(
            pretty_name(
                style_for(Some(r"C:\work\proj"), "file:///C:/work/proj/src/a.scss"),
                "file:///C:/work/proj/src/a.scss",
                Some(r"C:\work\proj"),
            )
            .as_deref(),
            Some(r"src\a.scss"),
        );
    }

    /// A UNC file URL carries its platform in the authority, and that is the
    /// only clue when no working directory was supplied — the legacy no-cwd
    /// wasm ABI, or an embedder that sets none. Read as POSIX it has no
    /// spelling at all, so the frame printed the URL.
    #[test]
    fn a_unc_url_is_windows_even_with_no_cwd() {
        assert_eq!(style_for(None, "file://server/share/a.scss"), Style::Windows);
        assert_eq!(
            pretty_name(
                style_for(None, "file://server/share/a.scss"),
                "file://server/share/a.scss",
                None,
            )
            .as_deref(),
            Some(r"\\server\share\a.scss"),
        );
        // `localhost` is the local machine, not a share: it must NOT flip the
        // style, or every plain file URL on POSIX would be read as Windows.
        assert_eq!(style_for(None, "file://localhost/a/b.scss"), HOST);
        assert_eq!(style_for(None, "file:///a/b.scss"), HOST);
    }

    /// The drive letter can arrive percent-encoded, and `file_url_path`
    /// decodes — so inferring the style from the RAW text disagreed with the
    /// function it was choosing the style for: `file:///C%3A/work/a.scss`
    /// came out as the POSIX path `/C:/work/a.scss`.
    #[test]
    fn an_encoded_drive_letter_is_still_a_drive() {
        assert_eq!(style_for(None, "file:///C%3A/work/a.scss"), Style::Windows);
        assert_eq!(
            pretty_name(
                style_for(None, "file:///C%3A/work/a.scss"),
                "file:///C%3A/work/a.scss",
                None,
            )
            .as_deref(),
            Some(r"C:\work\a.scss"),
        );
    }
}
