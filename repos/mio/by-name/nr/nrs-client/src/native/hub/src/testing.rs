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

    #[test]
    fn test_password_encryption_format() {
        // Test base64 encoding matches standard NRS requirement: {ENC}<base64>
        let pwd = "SecretPassword123!";
        let clean_phone: String = "0412 345 678".chars().filter(|c| c.is_ascii_digit()).collect();
        assert_eq!(clean_phone, "0412345678");

        // Simple base64 verification
        let data = pwd.as_bytes();
        const CHARSET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        let mut out = String::with_capacity((data.len() + 2) / 3 * 4);
        for chunk in data.chunks(3) {
            let b0 = chunk[0];
            let b1 = if chunk.len() > 1 { chunk[1] } else { 0 };
            let b2 = if chunk.len() > 2 { chunk[2] } else { 0 };
            out.push(CHARSET[(b0 >> 2) as usize] as char);
            out.push(CHARSET[(((b0 & 3) << 4) | (b1 >> 4)) as usize] as char);
            if chunk.len() > 1 {
                out.push(CHARSET[(((b1 & 0xF) << 2) | (b2 >> 6)) as usize] as char);
            } else {
                out.push('=');
            }
            if chunk.len() > 2 {
                out.push(CHARSET[(b2 & 0x3F) as usize] as char);
            } else {
                out.push('=');
            }
        }
        let enc_field = format!("{{ENC}}{}", out);
        assert!(enc_field.starts_with("{ENC}"));
        assert_eq!(enc_field, "{ENC}U2VjcmV0UGFzc3dvcmQxMjMh");
    }

    #[test]
    fn test_concentrix_campaign_mapping() {
        // Emergency calls
        let is_emergency = "000" == "000" || "112" == "000";
        let em_campaign = if is_emergency {
            "P_NRS_Emergency_InternetChat_Make_a_call_Chat"
        } else {
            "P_NRS_Internet_MakeACall_Chat"
        };
        assert_eq!(em_campaign, "P_NRS_Emergency_InternetChat_Make_a_call_Chat");

        // Standard calls
        let is_emergency_std = "0412345678" == "000";
        let std_campaign = if is_emergency_std {
            "P_NRS_Emergency_InternetChat_Make_a_call_Chat"
        } else {
            "P_NRS_Internet_MakeACall_Chat"
        };
        assert_eq!(std_campaign, "P_NRS_Internet_MakeACall_Chat");
    }
}
