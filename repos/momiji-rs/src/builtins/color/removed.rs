//! The nine legacy adjusters CSS Color 4 REMOVED from `sass:color`.
//!
//! `lighten`, `darken`, `saturate`, `desaturate`, `opacify`, `fade-in`,
//! `transparentize`, `fade-out` and `adjust-hue` still exist as GLOBAL
//! functions (deprecated, implemented in [`super::super::color_ext`]) but are
//! gone from the module, where dart-sass keeps a stub whose whole job is to
//! name the member, hand back a replacement computed from the call's own
//! arguments, and link the docs. They are real members for every other
//! purpose: `meta.function-exists`, `meta.get-function`, `@forward`, and a
//! `@use "sass:color" as *` that makes the bare name shadow the global.
//!
//! Three details of the replacement text look like they should come from the
//! `[color-functions]` deprecation next door ([`super::deprecate`]) and do not
//! — that one describes a call that SUCCEEDED, this one a call that cannot:
//!
//! - it echoes the call's own `$color` argument where the deprecation writes a
//!   `$color` placeholder;
//! - the negation is TEXTUAL, a `-` written in front of whatever the amount
//!   serialized to, so `darken($c, -10%)` recommends `$lightness: --10%`, `0%`
//!   recommends `-0%`, and `"x"` recommends `-"x"`;
//! - no unit conversion happens: `adjust-hue($c, 0.25turn)` recommends
//!   `$hue: 0.25turn`, where the deprecation would say `90deg`.
//!
//! The arguments are never validated — `color.lighten("nope", 10%)` reports the
//! same removal, with `"nope"` in the recommendation — but the ARITY is checked
//! first, by the declaration dart gives the stub (`$color, $amount`, for
//! `adjust-hue` too, where the global binds `$degrees`).
//!
//! Every shape here was measured against dart-sass 1.104.1 on 2026-09-19.

use super::super::{check_arity, require};
use crate::error::Error;
use crate::scanner::Pos;
use crate::value::Value;

/// The stub's own parameter list, which is what the arity error names.
const PARAMS: [&str; 2] = ["color", "amount"];

/// Each removed member: the `color.adjust` channel its replacement moves, and
/// whether the amount is negated on the way.
const REMOVED: [(&str, &str, bool); 9] = [
    ("adjust-hue", "hue", false),
    ("darken", "lightness", true),
    ("desaturate", "saturation", true),
    ("fade-in", "alpha", false),
    ("fade-out", "alpha", true),
    ("lighten", "lightness", false),
    ("opacify", "alpha", false),
    ("saturate", "saturation", false),
    ("transparentize", "alpha", true),
];

/// Whether `member` is one of the removed members — a `sass:color` member that
/// exists, and always fails. Callers pass the canonical spelling
/// (`color.fade_in` is `fade-in`).
pub(crate) fn is_member(member: &str) -> bool {
    REMOVED.iter().any(|(name, _, _)| *name == member)
}

/// Dispatch `color.<removed>(…)`. Always `Some(Err(…))` for a name this module
/// owns: there is no argument list that makes the call succeed.
pub(crate) fn call_module_member(
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    let (_, channel, negate) = *REMOVED.iter().find(|(name, _, _)| *name == member)?;
    Some(Err(error(member, channel, negate, pos_args, named, pos)))
}

/// dart's three-part message: what is gone, what to write instead, where to
/// read about it. The arity of the stub's declaration is reported first, so a
/// call that could not have bound its arguments says so rather than
/// recommending a replacement built from arguments it does not have.
fn error(
    member: &str,
    channel: &str,
    negate: bool,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Error {
    let bound = check_arity(2, pos_args, named, pos).and_then(|()| {
        let color = require(&PARAMS, pos_args, named, 0, pos)?;
        let amount = require(&PARAMS, pos_args, named, 1, pos)?;
        Ok((color, amount))
    });
    let (color, amount) = match bound {
        Ok(pair) => pair,
        Err(e) => return e,
    };
    let sign = if negate { "-" } else { "" };
    Error::at(
        format!(
            "The function {member}() isn't in the sass:color module.\n\
             \n\
             Recommendation: color.adjust({}, ${channel}: {sign}{})\n\
             \n\
             More info: https://sass-lang.com/documentation/functions/color#{member}",
            color.to_inspect_message(),
            amount.to_inspect_message(),
        ),
        pos,
    )
}

#[cfg(test)]
mod tests {
    use super::{is_member, REMOVED};

    /// The table is the set dart-sass removed, and nothing else. A name added
    /// here that dart still implements would turn a working call into an error.
    #[test]
    fn the_table_is_the_nine_removed_members() {
        let mut names: Vec<&str> = REMOVED.iter().map(|(n, _, _)| *n).collect();
        let sorted = names.clone();
        names.sort_unstable();
        assert_eq!(names, sorted, "keep REMOVED sorted by name");
        assert_eq!(
            names,
            [
                "adjust-hue",
                "darken",
                "desaturate",
                "fade-in",
                "fade-out",
                "lighten",
                "opacify",
                "saturate",
                "transparentize",
            ]
        );
    }

    /// The members that LOOK like these and are not: every one of them is still
    /// a live `sass:color` member, so claiming it here would break a call that
    /// works.
    #[test]
    fn the_surviving_members_are_not_claimed() {
        for name in [
            "adjust",
            "scale",
            "change",
            "alpha",
            "opacity",
            "grayscale",
            "invert",
            "complement",
            "mix",
            "hue",
            "saturation",
            "lightness",
            "whiteness",
            "blackness",
            "channel",
            "ie-hex-str",
        ] {
            assert!(!is_member(name), "`{name}` is still a member");
        }
    }
}
