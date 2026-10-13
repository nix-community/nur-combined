{
  lib,
  rustPlatform,
  sable-next,
  pkg-config,
  cargo-tauri,
  wrapGAppsHook3,
  makeBinaryWrapper,
  atk,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  libsoup_3,
  libxkbcommon,
  pango,
  pipewire,
  rust-jemalloc-sys,
  sqlite,
  webkitgtk_4_1,
  xz,
  stdenv,
  wayland,
  jq,
  moreutils,
  xdg-utils,
  libayatana-appindicator,
  gst_all_1,
  libGL,
  desktop-file-utils,
  conf ? { },
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sable-next-desktop";
  inherit (sable-next.unwrapped)
    version
    src
    cargoDeps
    ;

  __structuredAttrs = true;
  strictDeps = true;

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "wry"
  ];

  tauriBuildFlags = [
    "--no-sign"
  ];

  postPatch =
    let
      sable' = sable-next.override { inherit conf; };
    in
    ''
      ${lib.getExe jq} \
        '.build.frontendDist = "${sable'}"| del(.build.beforeBuildCommand) | .bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
        | ${lib.getExe' moreutils "sponge"} src-tauri/tauri.conf.json
    '';

  postInstall = ''
    mv $out/bin/app $out/bin/sable
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/bin"
    makeWrapper "$out/Applications/SableNext.app/Contents/MacOS/SableNext" "$out/bin/sable"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    desktop-file-edit \
      --set-key="Exec" --set-value="$out/bin/sable" \
      --set-key="StartupWMClass" --set-value="sable" \
      --set-comment "${finalAttrs.meta.description}" \
      --set-key="Categories" --set-value="Network;InstantMessaging;" \
      "$out/share/applications/Sable v2.desktop"
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs = [
    atk
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    libxkbcommon
    pango
    pipewire
    rust-jemalloc-sys
    sqlite
    webkitgtk_4_1
    xz
    libayatana-appindicator
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ])
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
  ];

  env.LIBSQLITE3_SYS_USE_PKG_CONFIG = true;

  checkFlags = [
    # These all require networking. What the-
    "--skip=account_lock::tests::lock_errors_preserve_tokens_and_are_distinct_from_expiry"
    "--skip=account_lock::tests::unlock_probes_require_the_same_account"
    "--skip=accounts::regression_tests::a_cache_reset_keeps_the_login_keys_and_search_index_but_not_the_sync_position"
    "--skip=accounts::regression_tests::a_hard_token_rejection_keeps_the_account"
    "--skip=accounts::regression_tests::a_refresh_during_an_abandoned_restore_is_saved"
    "--skip=accounts::regression_tests::confirmed_unencrypted_rooms_still_allow_plaintext_operations"
    "--skip=accounts::regression_tests::encryption_lookup_failure_prevents_plaintext_operations"
    "--skip=accounts::regression_tests::failed_switch_persistence_keeps_the_previous_session"
    "--skip=accounts::regression_tests::late_refresh_persists_after_teardown_and_reuses_live_client"
    "--skip=accounts::regression_tests::outgoing_credentials_survive_switch_without_resurrecting_accounts"
    "--skip=accounts::regression_tests::rejected_devices_discard_credentials_but_keep_their_stores"
    "--skip=accounts::regression_tests::rejected_tokens_stay_retired_when_the_registry_write_fails"
    "--skip=accounts::regression_tests::session_teardown_removes_thread_timelines"
    "--skip=accounts::regression_tests::session_teardown_waits_for_in_flight_timeline_builders"
    "--skip=accounts::regression_tests::switching_back_to_a_cached_client_rebuilds_one_set_of_handlers"
    "--skip=accounts::regression_tests::token_reload_reads_the_durable_session_and_refuses_retired_writers"
    "--skip=accounts::regression_tests::unknown_token_during_failed_preparation_still_ends_the_active_session"
    "--skip=auth::tests::a_login_persists_the_endpoint_it_was_built_at_not_the_advertised_one"
    "--skip=auth::tests::a_login_sends_the_identifier_kind_it_was_given"
    "--skip=auth::tests::a_rejected_reauthentication_logs_the_issued_session_out"
    "--skip=auth::tests::hard_logout_login_uses_a_new_device_and_store"
    "--skip=auth::tests::password_reauthentication_reuses_account_device_and_identity"
    "--skip=bot_commands::tests::only_joined_senders_advertise_commands"
    "--skip=bot_commands::tests::synced_command_descriptions_and_member_changes_are_announced"
    "--skip=calls::keys::sdk_tests::a_media_key_reaches_a_device_the_store_has_not_seen"
    "--skip=calls::membership::tests::state_membership_uses_its_custom_membership_id"
    "--skip=calls::membership::tests::state_memberships_survive_the_sdk_store_for_both_focus_modes"
    "--skip=calls::notify::sdk_tests::core_declines_legacy_notifications_but_rejects_invalid_and_own_events"
    "--skip=calls::runtime::tests::a_legacy_call_subscribes_to_another_focus_under_its_publishing_identity"
    "--skip=calls::runtime::tests::a_legacy_publisher_follows_the_oldest_members_focus"
    "--skip=calls::runtime::tests::a_legacy_publisher_stays_put_when_the_oldest_focus_will_not_let_it_publish"
    "--skip=calls::runtime::tests::a_publisher_refused_on_the_calls_focus_moves_to_its_own_in_every_mode"
    "--skip=calls::runtime::tests::an_element_call_focus_without_an_alias_still_counts"
    "--skip=calls::runtime::tests::an_element_call_peers_key_is_emitted_on_the_oldest_members_focus"
    "--skip=calls::runtime::tests::an_unchanged_roster_is_emitted_once"
    "--skip=calls::runtime::tests::joining_a_call_without_a_focus_uses_the_configured_fallback"
    "--skip=calls::runtime::tests::joining_an_existing_call_uses_the_oldest_focus_in_every_mode"
    "--skip=calls::runtime::tests::pending_key_with_a_custom_membership_id_is_emitted"
    "--skip=calls::runtime::tests::refresh_allows_a_recent_unobserved_membership"
    "--skip=calls::runtime::tests::refresh_stops_when_an_observed_membership_disappears"
    "--skip=calls::runtime::tests::refresh_stops_when_an_unobserved_membership_is_old"
    "--skip=calls::runtime::tests::schedule_hangup_does_not_write_when_delayed_events_are_unsupported"
    "--skip=calls::sfu::tests::matrix2_request_posts_to_the_root_get_token_endpoint"
    "--skip=calls::sticky::tests::test_delayed_send_includes_delay_and_sticky_duration"
    "--skip=calls::sticky::tests::test_delayed_send_refreshes_expired_credentials_and_preserves_sticky_query"
    "--skip=calls::sticky::tests::test_members_in_the_sdk_sticky_map_feed_the_call"
    "--skip=calls::sticky::tests::test_send_includes_sticky_duration_and_raw_content"
    "--skip=calls::sticky::tests::test_sticky_sync_accepts_an_empty_initial_extension_and_keeps_its_position"
    "--skip=calls::sticky::tests::test_sticky_sync_reuses_since_when_incremental_response_is_empty"
    "--skip=calls::sticky::tests::test_sticky_sync_sends_bounded_extensions_and_parses_both_event_locations"
    "--skip=cosmetics::tests::a_rename_in_one_room_refreshes_the_cached_space"
    "--skip=cosmetics::tests::a_rename_leaves_a_space_name_set_on_purpose"
    "--skip=cosmetics::tests::a_resent_member_state_re_reads_a_differing_layer_once"
    "--skip=cosmetics::tests::a_room_is_fetched_once_and_served_from_the_cache"
    "--skip=cosmetics::tests::a_synced_change_updates_the_cache_and_is_announced"
    "--skip=cosmetics::tests::concurrent_reads_of_one_room_share_a_single_fetch"
    "--skip=cosmetics::tests::only_parents_we_are_not_in_are_offered_canonical_first"
    "--skip=cosmetics::tests::without_a_space_the_first_parent_is_used"
    "--skip=dispatch::tests::caption_edit_retains_original_media_metadata"
    "--skip=dispatch::tests::soliditas_preview_asks_the_worker_with_the_url"
    "--skip=dispatch::tests::soliditas_preview_treats_a_refused_url_as_no_preview"
    "--skip=image_packs::server_tests::a_pack_sync_never_delivered_is_read_from_the_server"
    "--skip=image_packs::server_tests::a_refused_fetch_falls_back_to_the_last_fetched_pack"
    "--skip=image_packs::server_tests::a_refused_fetch_falls_back_to_the_stored_pack"
    "--skip=image_packs::server_tests::a_refused_state_fetch_falls_back_to_the_last_fetched_room_packs"
    "--skip=image_packs::server_tests::a_replaced_space_does_not_offer_its_packs"
    "--skip=image_packs::server_tests::a_room_pack_keeps_its_declared_meta_and_reports_both_formats"
    "--skip=image_packs::server_tests::a_synced_pack_edit_is_announced"
    "--skip=image_packs::server_tests::globally_selected_packs_precede_room_packs_including_the_current_room"
    "--skip=inbox::tests::a_cached_notification_does_not_stop_backfill_before_a_missing_one"
    "--skip=inbox::tests::a_direct_room_records_messages_the_push_rules_did_not_notify"
    "--skip=inbox::tests::an_unfetchable_receipt_event_falls_back_to_the_receipt_time"
    "--skip=inbox::tests::an_unknown_encryption_state_hides_the_inbox_preview"
    "--skip=inbox::tests::backfill_fetch_errors_are_reported_and_can_be_retried"
    "--skip=inbox::tests::delayed_receipt_does_not_hide_a_newer_unread_message"
    "--skip=inbox::tests::direct_filter_uses_current_room_status"
    "--skip=inbox::tests::highlights_keep_inbox_notifications_unread"
    "--skip=inbox::tests::unread_backfill_reaches_rooms_beyond_the_first_batch"
    "--skip=inbox::tests::unread_backfill_resumes_after_five_empty_pages"
    "--skip=invites::tests::triage_is_empty_without_invites"
    "--skip=invites::tests::triage_reads_the_reason_and_classifies_each_inviter"
    "--skip=media::avatar_import_tests::downloads_without_cors_headers_and_follows_redirects"
    "--skip=messages::tests::a_thread_timeline_is_already_at_its_end_going_forward"
    "--skip=messages::tests::edit_history_lists_the_original_then_valid_edits_by_time"
    "--skip=messages::tests::editing_a_pending_reply_updates_the_queue_and_keeps_the_relation"
    "--skip=messages::tests::event_items_render_the_latest_valid_edit_and_skip_missing_events"
    "--skip=messages::tests::forwarding_media_from_a_private_room_keeps_the_attachment"
    "--skip=messages::tests::forwarding_uses_latest_valid_edit_even_when_relations_are_unordered"
    "--skip=messages::tests::pin_and_unpin_load_existing_server_state"
    "--skip=messages::tests::reading_a_thread_sends_only_a_receipt_scoped_to_its_root"
    "--skip=notifications::tests::a_cold_client_does_not_refresh_while_the_foreground_owns_credentials"
    "--skip=notifications::tests::a_cold_push_cut_short_still_saves_the_rotated_tokens"
    "--skip=notifications::tests::a_cold_push_decrypts_from_androids_persisted_store"
    "--skip=notifications::tests::a_cold_push_failure_with_a_live_token_does_not_rotate_it"
    "--skip=notifications::tests::a_cold_push_in_an_all_messages_room_is_shown_under_a_mentions_default"
    "--skip=notifications::tests::a_cold_push_saves_the_tokens_it_refreshes"
    "--skip=notifications::tests::a_cold_push_the_push_rules_silence_is_discarded"
    "--skip=notifications::tests::a_cold_push_whose_rule_rings_is_marked_noisy"
    "--skip=notifications::tests::a_local_decryption_asks_for_the_key_quietly_only_when_every_encrypted_event_is_pushed"
    "--skip=notifications::tests::an_event_id_only_push_is_fetched_in_the_shape_of_a_rich_payload"
    "--skip=notifications::tests::pusher_name_lookup_failure_uses_the_fallback"
    "--skip=notifications::tests::pushers_use_the_current_device_name"
    "--skip=password_reset::tests::a_reset_retries_with_the_validated_email_after_the_uiaa_challenge"
    "--skip=password_reset::tests::a_server_without_email_reset_is_unsupported"
    "--skip=password_reset::tests::an_email_the_server_cannot_reset_is_reported_as_such"
    "--skip=password_reset::tests::an_unvalidated_email_asks_the_user_to_open_the_link"
    "--skip=push_check::tests::a_gateway_request_does_not_retry_an_http_error"
    "--skip=push_check::tests::a_gateway_request_retries_transient_connection_failures"
    "--skip=reactions::tests::a_redacted_message_shows_no_reactions"
    "--skip=reactions::tests::nested_reactions_are_ignored"
    "--skip=room_keys::tests::a_replaced_device_carries_its_room_keys_to_the_new_one"
    "--skip=room_keys::tests::a_wrong_passphrase_is_denied_and_a_damaged_file_is_invalid"
    "--skip=room_keys::tests::absent_cloud_backup_is_distinct_from_network_failure"
    "--skip=room_keys::tests::an_element_export_imports"
    "--skip=room_keys::tests::an_export_imports_into_another_device"
    "--skip=room_keys::tests::an_import_redecrypts_what_the_timeline_already_shows"
    "--skip=room_keys::tests::cloud_restore_batches_keys_preserves_backup_notifications_and_can_repeat"
    "--skip=room_keys::tests::cloud_restore_rejects_a_locked_or_mismatched_backup_before_downloading"
    "--skip=room_keys::tests::restored_backups_respect_the_account_preference"
    "--skip=room_keys::tests::switching_accounts_during_restore_keeps_keys_and_progress_with_the_owner"
    "--skip=rooms::tests::a_tombstone_with_an_empty_replacement_still_closes_the_room"
    "--skip=rooms::tests::upgrade_routes_include_the_tombstone_sender"
    "--skip=sdk_helpers_tests::a_cancelled_oauth_identity_reset_hands_back_no_key"
    "--skip=sdk_helpers_tests::a_pack_with_no_images_is_still_listed"
    "--skip=sdk_helpers_tests::a_refused_server_still_serves_what_is_cached"
    "--skip=sdk_helpers_tests::a_room_outside_the_list_still_has_a_summary"
    "--skip=sdk_helpers_tests::a_room_without_a_predecessor_names_none"
    "--skip=sdk_helpers_tests::a_server_whose_media_keeps_failing_is_refused_without_a_request"
    "--skip=sdk_helpers_tests::account_data_types_include_what_the_server_lists_but_sync_never_delivered"
    "--skip=sdk_helpers_tests::account_data_types_survive_a_restart_and_include_stored_known_types"
    "--skip=sdk_helpers_tests::adding_a_delisted_child_lists_it_again"
    "--skip=sdk_helpers_tests::adding_a_listed_child_keeps_its_edge"
    "--skip=sdk_helpers_tests::adding_a_new_child_routes_through_our_server"
    "--skip=sdk_helpers_tests::adding_a_suggested_child_marks_it"
    "--skip=sdk_helpers_tests::all_image_packs_return_without_waiting_for_room_state"
    "--skip=sdk_helpers_tests::an_approved_oauth_identity_reset_completes_its_session"
    "--skip=sdk_helpers_tests::an_encrypted_thumbnail_downloads_the_original"
    "--skip=sdk_helpers_tests::an_identity_reset_retries_a_wrong_password_and_returns_the_new_key"
    "--skip=sdk_helpers_tests::an_identity_reset_without_authentication_returns_the_new_key"
    "--skip=sdk_helpers_tests::an_original_streams_with_progress_and_is_cached"
    "--skip=sdk_helpers_tests::an_unencrypted_dm_request_reuses_an_unencrypted_dm"
    "--skip=sdk_helpers_tests::an_upgraded_room_names_its_predecessor_and_the_creators_servers"
    "--skip=sdk_helpers_tests::bulk_original_downloads_leave_all_preview_slots_available"
    "--skip=sdk_helpers_tests::cached_image_packs_return_without_waiting_for_room_state"
    "--skip=sdk_helpers_tests::cached_sticker_reads_bypass_six_stalled_downloads"
    "--skip=sdk_helpers_tests::corrupt_encrypted_media_is_rejected_before_returning_plaintext"
    "--skip=sdk_helpers_tests::device_rename_updates_pusher_state"
    "--skip=sdk_helpers_tests::devices_without_uploaded_crypto_keys_remain_visible"
    "--skip=sdk_helpers_tests::encryption_status_reports_a_passphrase_on_the_default_key"
    "--skip=sdk_helpers_tests::event_cached_reports_only_events_the_cache_holds"
    "--skip=sdk_helpers_tests::event_focus_clears_its_explicit_sync_subscription_after_unsubscribing"
    "--skip=sdk_helpers_tests::forbidden_media_never_opens_the_circuit"
    "--skip=sdk_helpers_tests::forgotten_media_is_fetched_again"
    "--skip=sdk_helpers_tests::healthy_space_summary_does_not_fetch_missing_tombstone_state"
    "--skip=sdk_helpers_tests::image_pack_listing_fetches_complete_state_when_one_pack_is_cached"
    "--skip=sdk_helpers_tests::large_cached_photos_do_not_replace_plain_thumbnails"
    "--skip=sdk_helpers_tests::legacy_original_downloads_can_take_longer_than_thirty_seconds"
    "--skip=sdk_helpers_tests::local_devices_never_ask_the_server"
    "--skip=sdk_helpers_tests::memberships_follow_the_server_joined_rooms"
    "--skip=sdk_helpers_tests::messaging_a_user_reuses_the_dm_that_already_exists"
    "--skip=sdk_helpers_tests::our_own_membership_is_fetched_for_small_rooms_that_lack_it"
    "--skip=sdk_helpers_tests::profile_updates_send_the_chosen_msc4466_propagation"
    "--skip=sdk_helpers_tests::queued_previews_recheck_the_original_cache"
    "--skip=sdk_helpers_tests::recover_identity_accepts_the_passphrase_as_well_as_the_key"
    "--skip=sdk_helpers_tests::recovery_adopts_an_account_data_key_that_seals_our_documents"
    "--skip=sdk_helpers_tests::reordering_a_child_keeps_its_via_and_suggestion"
    "--skip=sdk_helpers_tests::room_list_keeps_joined_rooms_redirected_to_a_joined_successor"
    "--skip=sdk_helpers_tests::room_members_use_cached_or_fetched_power_levels"
    "--skip=sdk_helpers_tests::scheduled_listing_refreshes_credentials_and_omits_finalized_events"
    "--skip=sdk_helpers_tests::sdk_original_retry_can_take_longer_than_thirty_seconds"
    "--skip=sdk_helpers_tests::sticker_previews_prefer_the_persisted_thumbnail_over_the_original"
    "--skip=sdk_helpers_tests::sticker_previews_reuse_a_cached_original_without_retrying_thumbnails"
    "--skip=sdk_helpers_tests::suggesting_a_child_keeps_its_via_and_order"
    "--skip=sdk_notification_tests::a_bridge_bot_still_counts_for_one_to_one_push_rules"
    "--skip=sdk_notification_tests::a_message_alerts_when_the_server_reports_no_counts"
    "--skip=sdk_notification_tests::a_message_delivered_late_by_a_resumed_sync_does_not_alert"
    "--skip=sdk_notification_tests::a_missing_rule_on_delete_is_not_a_failure"
    "--skip=sdk_notification_tests::a_pending_invite_does_not_make_a_room_one_to_one"
    "--skip=sdk_notification_tests::a_replayed_invite_alerts_once"
    "--skip=sdk_notification_tests::a_replayed_message_alerts_once"
    "--skip=sdk_notification_tests::a_second_room_mode_change_before_the_sync_echo_still_lands"
    "--skip=sdk_notification_tests::an_encrypted_room_defaults_to_the_rule_its_decrypted_messages_hit"
    "--skip=sdk_notification_tests::bridge_status_events_do_not_notify"
    "--skip=sdk_notification_tests::resetting_a_bridged_dm_to_default_does_not_create_a_room_push_rule"
    "--skip=sdk_notification_tests::sticker_notifications_do_not_block_sync_or_reappear_after_reading"
    "--skip=sdk_notification_tests::stripped_invite_notifies_without_an_invented_event_id"
    "--skip=sdk_timeline_tests::a_calendar_reload_reads_back_only_to_what_it_already_has"
    "--skip=sdk_timeline_tests::a_cleared_event_cache_does_not_end_history_at_the_next_arrival"
    "--skip=sdk_timeline_tests::a_count_truncated_by_the_local_cache_falls_back_to_the_server_count"
    "--skip=sdk_timeline_tests::a_deleted_mention_is_not_highlighted"
    "--skip=sdk_timeline_tests::a_failed_send_wedges_the_room_queue_until_it_is_re_enabled"
    "--skip=sdk_timeline_tests::a_forbidden_room_write_is_reported_as_denied"
    "--skip=sdk_timeline_tests::a_gallery_item_carries_what_a_single_attachment_does"
    "--skip=sdk_timeline_tests::a_gallery_mixing_a_picture_and_a_pdf_sends_each_as_its_own_itemtype"
    "--skip=sdk_timeline_tests::a_gallery_reaches_the_view_as_one_item_per_attachment"
    "--skip=sdk_timeline_tests::a_limited_sync_right_after_a_member_load_does_not_refetch_members"
    "--skip=sdk_timeline_tests::a_local_echo_keeps_the_formatted_body_it_was_sent_with"
    "--skip=sdk_timeline_tests::a_location_reaches_the_view_with_its_coordinates_parsed"
    "--skip=sdk_timeline_tests::a_mention_is_loud_from_the_ruleset_not_the_stamped_flag"
    "--skip=sdk_timeline_tests::a_new_calendar_room_is_set_up_by_its_creator"
    "--skip=sdk_timeline_tests::a_notice_is_marked_as_one_rather_than_read_as_speech"
    "--skip=sdk_timeline_tests::a_pin_change_reports_what_was_added_and_dropped"
    "--skip=sdk_timeline_tests::a_poll_carries_its_tally_and_the_answer_this_account_picked"
    "--skip=sdk_timeline_tests::a_poll_kind_we_do_not_recognise_withholds_its_tally"
    "--skip=sdk_timeline_tests::a_poll_that_repeats_an_answer_id_lists_it_once"
    "--skip=sdk_timeline_tests::a_private_reader_still_moves_the_marker_without_telling_the_room"
    "--skip=sdk_timeline_tests::a_rate_limited_room_write_carries_the_delay_in_milliseconds"
    "--skip=sdk_timeline_tests::a_receipt_on_the_latest_event_clears_a_stale_server_count"
    "--skip=sdk_timeline_tests::a_receipt_short_of_the_latest_message_leaves_the_marker"
    "--skip=sdk_timeline_tests::a_redaction_the_server_rejects_restores_the_message"
    "--skip=sdk_timeline_tests::a_renamed_room_carries_both_names_and_a_new_topic_carries_its_text"
    "--skip=sdk_timeline_tests::a_reply_quotes_formatted_text"
    "--skip=sdk_timeline_tests::a_reply_to_an_uncaptioned_gallery_quotes_its_file_names"
    "--skip=sdk_timeline_tests::a_room_read_elsewhere_reports_the_server_unread_count"
    "--skip=sdk_timeline_tests::a_room_that_starts_at_its_create_event_is_not_refetched"
    "--skip=sdk_timeline_tests::a_server_that_pushes_every_encrypted_event_does_not_count_them_as_unread"
    "--skip=sdk_timeline_tests::a_sticker_reaches_the_server_as_an_m_sticker_event"
    "--skip=sdk_timeline_tests::a_synced_calendar_entry_tells_the_page_to_reload"
    "--skip=sdk_timeline_tests::a_synced_state_event_drops_the_room_state_snapshot"
    "--skip=sdk_timeline_tests::a_time_element_survives_the_sdk_sanitizer"
    "--skip=sdk_timeline_tests::an_edit_renders_the_formatted_body_of_its_new_content"
    "--skip=sdk_timeline_tests::an_emptied_state_event_is_a_state_event_not_a_deleted_message"
    "--skip=sdk_timeline_tests::an_encrypted_private_space_includes_encryption_in_its_creation_request"
    "--skip=sdk_timeline_tests::an_invite_joined_without_a_required_state_member_becomes_joined"
    "--skip=sdk_timeline_tests::an_opened_room_stays_subscribed_after_another_room_opens"
    "--skip=sdk_timeline_tests::an_unavailable_homeserver_is_retryable_rather_than_a_logged_failure"
    "--skip=sdk_timeline_tests::an_undisclosed_poll_withholds_its_tally_until_it_closes"
    "--skip=sdk_timeline_tests::attachments_use_the_server_upload_limit_instead_of_100_mib"
    "--skip=sdk_timeline_tests::concurrent_first_access_returns_one_live_timeline"
    "--skip=sdk_timeline_tests::custom_room_state_reads_from_the_server_when_not_in_the_store"
    "--skip=sdk_timeline_tests::direct_room_summary_uses_the_other_members_avatar"
    "--skip=sdk_timeline_tests::explicit_room_subscription_delivers_simplified_sliding_sync_events"
    "--skip=sdk_timeline_tests::fetching_members_names_a_bridge_ghost_the_sync_never_shipped"
    "--skip=sdk_timeline_tests::hidden_events_admit_only_events_the_sdk_can_render"
    "--skip=sdk_timeline_tests::inactive_timelines_use_least_recently_used_eviction"
    "--skip=sdk_timeline_tests::invited_direct_room_summary_is_direct"
    "--skip=sdk_timeline_tests::joining_a_call_is_worded_as_a_join"
    "--skip=sdk_timeline_tests::live_location_beacons_reach_the_view_as_updated_coordinates"
    "--skip=sdk_timeline_tests::live_timeline_back_paginates_through_the_event_cache"
    "--skip=sdk_timeline_tests::live_timeline_receives_sync_and_reconciles_a_limited_gap"
    "--skip=sdk_timeline_tests::live_timeline_reports_its_back_pagination_status"
    "--skip=sdk_timeline_tests::marking_a_room_read_uses_the_latest_threaded_event"
    "--skip=sdk_timeline_tests::marking_read_publishes_a_receipt_and_moves_the_marker"
    "--skip=sdk_timeline_tests::marking_unread_from_a_message_walks_the_read_marker_back"
    "--skip=sdk_timeline_tests::marking_unread_writes_the_room_account_data_flag"
    "--skip=sdk_timeline_tests::media_config_is_cached_per_account_and_supports_legacy_servers"
    "--skip=sdk_timeline_tests::media_replies_preserve_silent_mentions_on_the_wire"
    "--skip=sdk_timeline_tests::missing_room_state_is_remembered_until_it_is_written"
    "--skip=sdk_timeline_tests::opening_a_room_and_its_cosmetics_fetch_its_state_once"
    "--skip=sdk_timeline_tests::permalink_timeline_loads_and_contains_its_target"
    "--skip=sdk_timeline_tests::redacting_an_event_outside_the_timeline_redacts_it_in_the_room"
    "--skip=sdk_timeline_tests::reopening_a_room_reuses_the_state_it_probed"
    "--skip=sdk_timeline_tests::replies_to_state_and_membership_events_carry_no_body"
    "--skip=sdk_timeline_tests::room_summary_clears_removed_avatars_when_rooms_are_reinserted"
    "--skip=sdk_timeline_tests::sliding_sync_room_summary_prefers_avatar_state_over_the_avatar_property"
    "--skip=sdk_timeline_tests::started_sync_recovers_after_an_offline_failure"
    "--skip=sdk_timeline_tests::the_read_marker_falls_back_to_the_read_receipt"
    "--skip=sdk_timeline_tests::the_read_marker_is_the_fully_read_event"
    "--skip=sdk_timeline_tests::timeline_subscriptions_remain_active_until_each_is_unsubscribed"
    "--skip=sdk_timeline_tests::timeline_view_preserves_available_read_receipt_timestamps"
    "--skip=sdk_timeline_tests::unread_reply_counts_persist_until_read"
    "--skip=sdk_timeline_tests::warmed_rooms_join_the_subscription_set_up_to_a_cap"
    "--skip=sdk_verification_tests::a_self_verification_completes_with_a_qr_code"
    "--skip=sdk_verification_tests::both_devices_choosing_emoji_at_once_converge_on_one_comparison"
    "--skip=sdk_verification_tests::choosing_emoji_after_a_qr_scan_does_not_leave_either_side_waiting"
    "--skip=sdk_verification_tests::crossed_self_verification_requests_are_cancelled_without_retrying"
    "--skip=sdk_verification_tests::history_bundles_require_owner_signed_recipient_devices"
    "--skip=sdk_verification_tests::the_account_data_key_is_shared_only_with_a_verified_own_device"
    "--skip=sdk_verification_tests::the_requester_accepts_an_emoji_start_from_the_other_device"
    "--skip=search::crawl::tests::test_a_checkpoint_is_not_persisted_ahead_of_the_documents_it_skips"
    "--skip=search::crawl::tests::test_a_room_that_is_gone_is_not_written_off_for_good"
    "--skip=search::crawl::tests::test_a_room_without_a_cursor_starts_behind_what_sync_delivered"
    "--skip=search::crawl::tests::test_a_server_error_backs_the_crawl_off_instead_of_dropping_the_room"
    "--skip=search::crawl::tests::test_a_session_that_failed_once_is_not_decrypted_again"
    "--skip=search::crawl::tests::test_checkpoints_written_by_main_survive_the_upgrade"
    "--skip=search::crawl::tests::test_disabling_the_crawler_stops_search_coverage"
    "--skip=search::crawl::tests::test_metered_crawl_cancels_requests"
    "--skip=search::crawl::tests::test_metered_crawl_pauses_and_resumes"
    "--skip=search::crawl::tests::test_the_crawl_reaches_an_encrypted_room_before_one_the_server_can_search"
    "--skip=search::crawl::tests::test_the_crawl_stops_a_room_below_its_floor"
    "--skip=search::crawl::tests::test_the_crawl_stops_a_room_older_than_its_age_limit"
    "--skip=search::crawl::tests::test_the_metrics_count_batches_and_pushbacks"
    "--skip=search::tests::test_a_dated_query_stays_local_even_for_an_unencrypted_room"
    "--skip=search::tests::test_a_failed_room_reports_partial_not_complete"
    "--skip=search::tests::test_a_filter_only_query_stays_local_even_for_an_unencrypted_room"
    "--skip=search::tests::test_a_flushed_index_is_searchable_in_the_next_session"
    "--skip=search::tests::test_a_homeserver_that_cannot_search_falls_back_to_the_local_index"
    "--skip=search::tests::test_a_redaction_drops_the_message_from_the_index"
    "--skip=search::tests::test_a_redaction_of_an_unloaded_message_is_purged_from_disk"
    "--skip=search::tests::test_a_restored_room_does_not_charge_the_crawl_budget_again"
    "--skip=search::tests::test_a_room_left_between_sessions_is_wiped_at_restore"
    "--skip=search::tests::test_a_room_walked_to_its_start_reports_complete"
    "--skip=search::tests::test_a_room_with_no_new_activity_is_indexed_from_its_persisted_cache"
    "--skip=search::tests::test_a_spent_budget_reports_stopped_even_with_rooms_left"
    "--skip=search::tests::test_a_stale_derivation_keeps_documents_and_opens_a_rederive_window"
    "--skip=search::tests::test_a_thread_reply_is_marked_and_keeps_the_mark_through_an_edit"
    "--skip=search::tests::test_a_v3_blob_from_main_is_split_into_chunks_without_a_recrawl"
    "--skip=search::tests::test_an_edit_crawled_a_batch_before_its_original_is_fixed_up_when_it_lands"
    "--skip=search::tests::test_an_edit_crawled_before_its_original_keeps_the_new_body"
    "--skip=search::tests::test_an_edit_from_someone_else_is_ignored"
    "--skip=search::tests::test_an_edit_keeps_the_originals_time_and_takes_its_new_mentions"
    "--skip=search::tests::test_an_encrypted_room_is_never_searched_on_the_homeserver"
    "--skip=search::tests::test_an_encrypted_rooms_plaintext_is_searchable_and_edits_replace_the_body"
    "--skip=search::tests::test_an_older_page_is_capped_and_resumes_inside_the_chunk"
    "--skip=search::tests::test_an_unencrypted_room_is_searched_on_the_homeserver"
    "--skip=search::tests::test_back_pagination_reaches_the_index_and_notifies_it"
    "--skip=search::tests::test_ignored_senders_are_read_from_the_store"
    "--skip=search::tests::test_leaving_a_room_forgets_its_documents"
    "--skip=search::tests::test_older_pages_search_what_is_only_on_disk"
    "--skip=search::tests::test_one_older_page_keeps_scanning_until_it_finds_something"
    "--skip=search::tests::test_only_the_crawl_rederives_classified_documents"
    "--skip=search::tests::test_pagination_walks_one_ordering_without_repeating_a_hit"
    "--skip=search::tests::test_redacting_an_edit_brings_the_previous_body_back"
    "--skip=search::tests::test_room_attachments_list_each_gallery_item_under_its_tab"
    "--skip=search::tests::test_room_attachments_sort_the_index_into_media_files_and_links"
    "--skip=search::tests::test_search_watcher_releases_paginated_room_cache"
    "--skip=search::tests::test_the_crawl_resumes_from_the_checkpoint_it_persisted"
    "--skip=search::tests::test_the_crawl_serves_every_room_before_deepening_one"
    "--skip=search::tests::test_the_crawler_deepens_a_room_and_records_reaching_its_start"
    "--skip=search::tests::test_the_gallery_fills_in_media_for_a_migrated_message"
    "--skip=session::tests::account_clients_decrypt_messages_from_all_devices"
    "--skip=session::tests::clearing_disposable_cache_keeps_the_encryption_identity"
    "--skip=session::tests::empty_crypto_store_does_not_recreate_an_existing_device"
    "--skip=session::tests::idle_desktop_crypto_store_does_not_write"
    "--skip=session::tests::relocated_legacy_store_preserves_the_device_encryption_identity"
    "--skip=session::tests::repairs_room_key_sharing_once_per_account"
    "--skip=session::tests::resolved_endpoint_restores_without_discovery"
    "--skip=session::tests::restoring_a_different_device_refuses_the_saved_crypto_identity"
    "--skip=spaces::server_tests::an_account_that_never_arranged_the_rail_has_no_layout"
    "--skip=spaces::server_tests::reads_a_layout_sync_delivered"
    "--skip=spaces::server_tests::writing_keeps_the_keys_it_does_not_model"
    "--skip=sync_support::tests::support_checks_distinguish_unsupported_servers_from_failures"
    "--skip=v1_migration::tests::changed_oauth_issuer_is_rejected_before_restoring_tokens"
    "--skip=watchers::tests::a_rename_carries_the_room_and_the_new_profile"
    "--skip=watchers::tests::a_timeline_rename_without_prev_content_still_counts"
    "--skip=webpush::tests::a_capability_alone_announces_the_homeserver_delivery"
    "--skip=webpush::tests::a_feature_without_a_capability_makes_no_homeserver_delivery"
    "--skip=webpush::tests::the_stable_capability_is_read_without_the_unstable_feature"
    "--skip=widgets::tests::a_clear_to_device_message_goes_out_in_one_request_and_internal_types_are_dropped"
    "--skip=widgets::tests::a_delayed_state_event_carries_the_delay"
    "--skip=widgets::tests::a_delayed_sticky_event_carries_its_duration_and_stays_clear_only_for_rtc_members"
    "--skip=widgets::tests::a_missing_livekit_endpoint_reads_as_unsupported"
    "--skip=widgets::tests::a_sticky_event_carries_its_duration"
    "--skip=widgets::tests::a_widget_state_change_tells_the_room_to_reload_its_widgets"
    "--skip=widgets::tests::an_encrypted_to_device_message_to_an_unknown_device_sends_nothing"
    "--skip=widgets::tests::known_rooms_are_the_joined_ones"
    "--skip=widgets::tests::relations_come_back_with_their_room_id_and_the_event_type_filter"
    "--skip=widgets::tests::restarting_a_delayed_event_posts_the_restart_action"
    "--skip=widgets::tests::rtc_transports_are_relayed_as_the_homeserver_describes_them"
    "--skip=widgets::tests::sticky_reads_come_from_the_sdk_sticky_map"
    "--skip=widgets::tests::the_feed_forwards_synced_events_only_while_it_is_on"
    "--skip=widgets::tests::the_integration_manager_page_carries_a_scalar_token_from_the_openid_exchange"
    "--skip=widgets::tests::the_livekit_requests_carry_the_widget_body_verbatim"
    "--skip=widgets::tests::turn_credentials_report_their_lifetime_in_milliseconds"
    "--skip=widgets::tests::widget_sends_return_the_created_event_id"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libayatana-appindicator
          libGL
          libxkbcommon
        ]
      }"
    )
  '';

  meta = {
    inherit (sable-next.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;

    mainProgram = "sable";
  };
})
