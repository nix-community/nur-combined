#!/usr/bin/env nix-shell
#!nix-shell -i sh -p iw gawk gnugrep coreutils

# https://github.com/openwrt/openwrt/blob/master/package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh
# awk '{print $1}' | sed 's/:/=/'

phy=phy$1

mac80211_add_capabilities() {
  local __var="$1"; shift
  local __mask="$1"; shift
  local __out= oifs

  oifs="$IFS"
  IFS=:
  for capab in "$@"; do
    set -- $capab

    [ "$(($4))" -gt 0 ] || continue
    [ "$(($__mask & $2))" -eq "$((${3:-$2}))" ] || continue
    __out="$__out[$1]"
  done
  IFS="$oifs"

  export -n -- "$__var=$__out"
}

mac80211_add_he_capabilities() {
	local __out= oifs

	oifs="$IFS"
	IFS=:
	for capab in "$@"; do
		set -- $capab
		[ "$(($4))" -gt 0 ] || continue
		[ "$(((0x$2) & $3))" -gt 0 ] || {
			eval "$1=0"
			continue
		}
		echo "$1=1" "$N"
	done
	IFS="$oifs"
}

# n
ldpc=1
greenfield=0
short_gi_20=1
short_gi_40=1
tx_stbc=1
rx_stbc=3
max_amsdu=1
dsss_cck_40=1

		ht_cap_mask=0
		for cap in $(iw phy "$phy" info | grep 'Capabilities:' | cut -d: -f2); do
			ht_cap_mask="$(($ht_cap_mask | $cap))"
		done

		cap_rx_stbc=$((($ht_cap_mask >> 8) & 3))
		[ "$rx_stbc" -lt "$cap_rx_stbc" ] && cap_rx_stbc="$rx_stbc"
		ht_cap_mask="$(( ($ht_cap_mask & ~(0x300)) | ($cap_rx_stbc << 8) ))"

		mac80211_add_capabilities ht_capab_flags $ht_cap_mask \
			LDPC:0x1::$ldpc \
			GF:0x10::$greenfield \
			SHORT-GI-20:0x20::$short_gi_20 \
			SHORT-GI-40:0x40::$short_gi_40 \
			TX-STBC:0x80::$tx_stbc \
			RX-STBC1:0x300:0x100:1 \
			RX-STBC12:0x300:0x200:1 \
			RX-STBC123:0x300:0x300:1 \
			MAX-AMSDU-7935:0x800::$max_amsdu \
			DSSS_CCK-40:0x1000::$dsss_cck_40

    ht_capab="$ht_capab$ht_capab_flags"

# ac
rxldpc=1
short_gi_80=1
short_gi_160=1
tx_stbc_2by1=1
su_beamformer=1
su_beamformee=1
mu_beamformer=1
mu_beamformee=1
vht_txop_ps=1
htc_vht=1
beamformee_antennas=4
beamformer_antennas=4
rx_antenna_pattern=1
tx_antenna_pattern=1
vht_max_a_mpdu_len_exp=7
vht_max_mpdu=11454
rx_stbc=4
vht_link_adapt=3
vht160=2

vht_cap=0
for cap in $(iw phy "$phy" info | awk -F "[()]" '/VHT Capabilities/ { print $2 }'); do
  vht_cap="$(($vht_cap | $cap))"
done

cap_rx_stbc=$((($vht_cap >> 8) & 7))
[ "$rx_stbc" -lt "$cap_rx_stbc" ] && cap_rx_stbc="$rx_stbc"
vht_cap="$(( ($vht_cap & ~(0x700)) | ($cap_rx_stbc << 8) ))"

		mac80211_add_capabilities vht_capab $vht_cap \
			RXLDPC:0x10::$rxldpc \
			SHORT-GI-80:0x20::$short_gi_80 \
			SHORT-GI-160:0x40::$short_gi_160 \
			TX-STBC-2BY1:0x80::$tx_stbc_2by1 \
			SU-BEAMFORMER:0x800::$su_beamformer \
			SU-BEAMFORMEE:0x1000::$su_beamformee \
			MU-BEAMFORMER:0x80000::$mu_beamformer \
			MU-BEAMFORMEE:0x100000::$mu_beamformee \
			VHT-TXOP-PS:0x200000::$vht_txop_ps \
			HTC-VHT:0x400000::$htc_vht \
			RX-ANTENNA-PATTERN:0x10000000::$rx_antenna_pattern \
			TX-ANTENNA-PATTERN:0x20000000::$tx_antenna_pattern \
			RX-STBC-1:0x700:0x100:1 \
			RX-STBC-12:0x700:0x200:1 \
			RX-STBC-123:0x700:0x300:1 \
			RX-STBC-1234:0x700:0x400:1 \

		[ "$(($vht_cap & 0x800))" -gt 0 -a "$su_beamformer" -gt 0 ] && {
			cap_ant="$(( ( ($vht_cap >> 16) & 3 ) + 1 ))"
			[ "$cap_ant" -gt "$beamformer_antennas" ] && cap_ant="$beamformer_antennas"
			[ "$cap_ant" -gt 1 ] && vht_capab="$vht_capab[SOUNDING-DIMENSION-$cap_ant]"
		}

		[ "$(($vht_cap & 0x1000))" -gt 0 -a "$su_beamformee" -gt 0 ] && {
			cap_ant="$(( ( ($vht_cap >> 13) & 3 ) + 1 ))"
			[ "$cap_ant" -gt "$beamformee_antennas" ] && cap_ant="$beamformee_antennas"
			[ "$cap_ant" -gt 1 ] && vht_capab="$vht_capab[BF-ANTENNA-$cap_ant]"
		}

		# supported Channel widths
		vht160_hw=0
		[ "$(($vht_cap & 12))" -eq 4 -a 1 -le "$vht160" ] && \
			vht160_hw=1
		[ "$(($vht_cap & 12))" -eq 8 -a 2 -le "$vht160" ] && \
			vht160_hw=2
		[ "$vht160_hw" = 1 ] && vht_capab="$vht_capab[VHT160]"
		[ "$vht160_hw" = 2 ] && vht_capab="$vht_capab[VHT160-80PLUS80]"

		# maximum MPDU length
		vht_max_mpdu_hw=3895
		[ "$(($vht_cap & 3))" -ge 1 -a 7991 -le "$vht_max_mpdu" ] && \
			vht_max_mpdu_hw=7991
		[ "$(($vht_cap & 3))" -ge 2 -a 11454 -le "$vht_max_mpdu" ] && \
			vht_max_mpdu_hw=11454
		[ "$vht_max_mpdu_hw" != 3895 ] && \
			vht_capab="$vht_capab[MAX-MPDU-$vht_max_mpdu_hw]"

		# maximum A-MPDU length exponent
		vht_max_a_mpdu_len_exp_hw=0
		[ "$(($vht_cap & 58720256))" -ge 8388608 -a 1 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=1
		[ "$(($vht_cap & 58720256))" -ge 16777216 -a 2 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=2
		[ "$(($vht_cap & 58720256))" -ge 25165824 -a 3 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=3
		[ "$(($vht_cap & 58720256))" -ge 33554432 -a 4 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=4
		[ "$(($vht_cap & 58720256))" -ge 41943040 -a 5 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=5
		[ "$(($vht_cap & 58720256))" -ge 50331648 -a 6 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=6
		[ "$(($vht_cap & 58720256))" -ge 58720256 -a 7 -le "$vht_max_a_mpdu_len_exp" ] && \
			vht_max_a_mpdu_len_exp_hw=7
		vht_capab="$vht_capab[MAX-A-MPDU-LEN-EXP$vht_max_a_mpdu_len_exp_hw]"

		# whether or not the STA supports link adaptation using VHT variant
		vht_link_adapt_hw=0
		[ "$(($vht_cap & 201326592))" -ge 134217728 -a 2 -le "$vht_link_adapt" ] && \
			vht_link_adapt_hw=2
		[ "$(($vht_cap & 201326592))" -ge 201326592 -a 3 -le "$vht_link_adapt" ] && \
			vht_link_adapt_hw=3
		[ "$vht_link_adapt_hw" != 0 ] && \
			vht_capab="$vht_capab[VHT-LINK-ADAPT-$vht_link_adapt_hw]"

# ax
he_su_beamformer=1
he_su_beamformee=0
he_mu_beamformer=1
he_twt_required=0
he_spr_sr_control=0
he_spr_non_srg_obss_pd_max_offset=1

		he_phy_cap=$(iw phy "$phy" info | awk -F "[()]" '/HE PHY Capabilities/ { print $2 }' | head -1)
		he_phy_cap=${he_phy_cap:2}
		he_mac_cap=$(iw phy "$phy" info | awk -F "[()]" '/HE MAC Capabilities/ { print $2 }' | head -1)
		he_mac_cap=${he_mac_cap:2}

		mac80211_add_he_capabilities \
			he_su_beamformer:${he_phy_cap:6:2}:0x80:$he_su_beamformer \
			he_su_beamformee:${he_phy_cap:8:2}:0x1:$he_su_beamformee \
			he_mu_beamformer:${he_phy_cap:8:2}:0x2:$he_mu_beamformer \
			he_spr_sr_control:${he_phy_cap:14:2}:0x1:$he_spr_sr_control \
			he_twt_required:${he_mac_cap:0:2}:0x6:$he_twt_required

echo $ht_capab
echo $vht_capab
