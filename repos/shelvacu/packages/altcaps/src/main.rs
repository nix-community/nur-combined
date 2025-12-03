use std::ffi::OsString;
use std::borrow::Cow;

use itertools::Itertools;

fn main() {
    let mut args = std::env::args_os();
    args.next().expect("There should always be an argv[0] (program name)");
    let mut the_string;
    if args.len() > 0 {
        let the_str_os:OsString = itertools::Itertools::intersperse(args, " ".into()).collect();
        the_string = the_str_os.into_string().expect("Passed arg is not valid utf-8");
    } else {
        let stdin = std::io::stdin();
        eprint!("Type your message: ");
        the_string = String::new();
        stdin.read_line(&mut the_string).unwrap();
        the_string.truncate(the_string.len() - 1);
    }
    print!("{}", alternate_caps(the_string.as_str()));
}

fn alternate_caps(old_s: &str) -> String {
    let segmenter = icu_segmenter::GraphemeClusterSegmenter::new();
    let li = icu_locale::langid!("en-US");
    let casemapper = icu_casemap::CaseMapper::new();
    let mut new_s = String::with_capacity(old_s.len());
    let mut caps = false;
    for cluster in segmenter.segment_str(old_s).tuple_windows().map(|(i, j)| &old_s[i..j]) {
        // dbg!(cluster, caps);
        // for readability, always lowercase i and capitalize L
        let new_cluster:Cow<str>;
        if cluster == "I" || cluster == "i" {
            new_cluster = "i".into();
            caps = true;
        } else if cluster == "L" || cluster == "l" {
            new_cluster = "L".into();
            caps = false;
        } else {
            let uppercase_version = casemapper.uppercase_to_string(cluster, &li);
            let lowercase_version = casemapper.lowercase_to_string(cluster, &li);
            let case_equiv = uppercase_version == lowercase_version;
            // dbg!(&uppercase_version, &lowercase_version, case_equiv);
            new_cluster = if caps {
                uppercase_version
            } else {
                lowercase_version
            };
            // dbg!(&new_cluster);
            if !case_equiv {
                caps = !caps;
            }
        }
        new_s.push_str(&new_cluster);
    }
    new_s
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test1() {
        assert_eq!(alternate_caps("hello"), "hELLo");
        assert_eq!(alternate_caps("this is a message"), "tHiS iS a MeSsAgE");
        assert_eq!(alternate_caps("That's an anachronism"), "tHaT's An AnAcHrOniSm");
    }
}
