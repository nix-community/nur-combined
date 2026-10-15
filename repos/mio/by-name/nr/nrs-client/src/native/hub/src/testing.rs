#[cfg(test)]
mod tests {
    #[test]
    fn test_relay_turn_tokens() {
        let msg1 = "Hello, I am calling regarding my account GA";
        assert!(msg1.ends_with("GA"));

        let msg2 = "Goodbye then. SKSK";
        assert!(msg2.ends_with("SKSK"));

        let msg3 = "Ready to finish call GA TO SK";
        assert!(msg3.ends_with("GA TO SK"));
    }

    #[test]
    fn test_auto_append_ga() {
        let text = "Please check invoice number 12345";
        let mut formatted = text.to_string();
        if !formatted.ends_with("GA") && !formatted.ends_with("SK") {
            formatted.push_str(" GA");
        }
        assert_eq!(formatted, "Please check invoice number 12345 GA");

        // If already ending with GA, should not double append
        let text2 = "Already has GA";
        let mut formatted2 = text2.to_string();
        if !formatted2.ends_with("GA") && !formatted2.ends_with("SK") {
            formatted2.push_str(" GA");
        }
        assert_eq!(formatted2, "Already has GA");
    }

    #[test]
    fn test_transcript_formatting() {
        let messages = vec![
            ("10:00:01", "RO_SYSTEM", "National Relay Service. RO 4821. GA"),
            ("10:00:15", "USER", "Please call 02 9876 5432 GA"),
            ("10:00:30", "RO_SYSTEM", "Dialing... Party answered."),
            ("10:00:45", "OFFICER_SPEECH", "Hello, Accounts speaking GA"),
            ("10:01:00", "USER", "Thanks, all sorted. SK"),
            ("10:01:10", "OFFICER_SPEECH", "Goodbye SKSK"),
        ];

        let mut transcript = String::new();
        for (time, sender, text) in messages {
            transcript.push_str(&format!("[{}] {}: {}\n", time, sender, text));
        }

        assert!(transcript.contains("[10:00:15] USER: Please call 02 9876 5432 GA"));
        assert!(transcript.contains("[10:01:10] OFFICER_SPEECH: Goodbye SKSK"));
    }
}
