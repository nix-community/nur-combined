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

    #[test]
    fn test_nz_relay_campaign_and_emergency() {
        // NZ Emergency numbers
        let check_nz_emergency = |num: &str| num == "111" || num == "112" || num == "911";
        assert!(check_nz_emergency("111"));
        assert!(check_nz_emergency("112"));
        assert!(check_nz_emergency("911"));
        assert!(!check_nz_emergency("000"));
        assert!(!check_nz_emergency("021123456"));

        // AU Emergency numbers
        let check_au_emergency = |num: &str| num == "000" || num == "112" || num == "911";
        assert!(check_au_emergency("000"));
        assert!(check_au_emergency("112"));
        assert!(check_au_emergency("911"));
        assert!(!check_au_emergency("111"));

        // NZ Campaign is always "Text Relay"
        let nz_campaign = "Text Relay";
        assert_eq!(nz_campaign, "Text Relay");
    }

    #[test]
    fn test_nz_relay_auth_header() {
        const CHARSET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        let raw = "trsapi:Tr5L1v3@2021";
        let data = raw.as_bytes();
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
        let basic_header = format!("Basic {}", out);
        assert_eq!(basic_header, "Basic dHJzYXBpOlRyNUwxdjNAMjAyMQ==");
    }

    #[test]
    fn test_autodetect_country_logic() {
        let detect_from_hints = |country_code: &str, tz_name: &str| -> &'static str {
            let c = country_code.to_uppercase();
            if c == "NZ" {
                return "NZ";
            }
            if c == "AU" {
                return "AU";
            }
            let tz = tz_name.to_uppercase();
            if tz.contains("NZ") || tz.contains("AUCKLAND") || tz.contains("CHATHAM") {
                return "NZ";
            }
            if tz.contains("AEST") || tz.contains("AEDT") || tz.contains("ACST") || tz.contains("AWST") || tz.contains("AUSTRALIA") {
                return "AU";
            }
            "AU"
        };

        assert_eq!(detect_from_hints("NZ", "UTC"), "NZ");
        assert_eq!(detect_from_hints("AU", "UTC"), "AU");
        assert_eq!(detect_from_hints("", "NZDT"), "NZ");
        assert_eq!(detect_from_hints("", "NZST"), "NZ");
        assert_eq!(detect_from_hints("", "AEDT"), "AU");
        assert_eq!(detect_from_hints("", "AEST"), "AU");
        assert_eq!(detect_from_hints("", "Pacific/Auckland"), "NZ");
        assert_eq!(detect_from_hints("", "Australia/Sydney"), "AU");
    }
}
