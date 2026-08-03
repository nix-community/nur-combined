//! Menu history-slice tests — pin down fix e5a583d (the inverter used to
//! show ancient colors instead of the recent ones).

use super::slice_history_for_menu;

fn history() -> Vec<String> {
    // newest-first, as push_history stores it: n1 is the most recent pick.
    ["n1", "n2", "n3", "n4", "n5"].iter().map(|s| s.to_string()).collect()
}

#[test]
fn test_default_order_recent_first() {
    assert_eq!(slice_history_for_menu(&history(), 2, false), vec!["n1", "n2"]);
}

#[test]
fn test_reverse_inverts_the_recent_slice_not_the_whole_history() {
    // Regression e5a583d: with the inverter this used to be ["n5", "n4"] — ancient.
    assert_eq!(slice_history_for_menu(&history(), 2, true), vec!["n2", "n1"]);
}

#[test]
fn test_show_larger_than_history() {
    assert_eq!(slice_history_for_menu(&history(), 99, false).len(), 5);
    assert_eq!(slice_history_for_menu(&history(), 99, true), vec!["n5", "n4", "n3", "n2", "n1"]);
}

#[test]
fn test_empty_history() {
    assert!(slice_history_for_menu(&[], 10, false).is_empty());
    assert!(slice_history_for_menu(&[], 10, true).is_empty());
}
