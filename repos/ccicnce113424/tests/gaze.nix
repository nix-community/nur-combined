{ lib, ... }:
{
  name = "gaze";

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
  };

  nodes.machine = {
    # What the upstream documentation wires the Cinnamon lock screen with; the
    # module itself has no Cinnamon options.
    security.pam.services.cinnamon-screensaver.gaze.enable = true;

    services.gaze = {
      enable = true;
      gui.enable = true;
      gnome.enable = true;
      kde = {
        lockScreen = true;
        loginScreen = true;
        unlockKwallet = true;
      };
    };
  };

  testScript = ''
    def auth_rules(service):
        """The `auth` rules of a PAM service, in the order they run."""
        return [
            line
            for line in machine.succeed(f"cat /etc/pam.d/{service}").splitlines()
            if line.startswith("auth ")
        ]


    def auth_position(service, needle):
        rules = auth_rules(service)
        positions = [i for i, line in enumerate(rules) if needle in line]
        assert positions, f"{service} has no auth rule containing {needle!r}"
        return positions[0]


    machine.start()
    machine.wait_for_unit("multi-user.target")

    # The daemon unit is wired up and its state directory is private.
    machine.succeed("systemctl is-enabled gazed.service")
    machine.succeed("test \"$(stat -c %a /var/lib/gaze)\" = 700")
    machine.succeed("test -d /var/cache/gaze")

    # `kde.unlockKwallet` also carries its runtime opt-in into the seeded
    # configuration, next to the sealed-template prerequisite.
    config = machine.succeed("cat /etc/gaze/config.toml")
    assert "unlock_kwallet = true" in config
    assert "encrypt_templates = true" in config

    # The daemon prepares its model cache on first start and this VM has no
    # network, so the run below stops at the download. It still proves that the
    # binary, the ONNX Runtime it dlopens, and its configuration are in place.
    machine.systemctl("stop gazed.service")
    machine.succeed(
        "(timeout 120 gazed 2>&1 || true) | grep -q 'Downloading model file'"
    )

    # The system bus configuration includes the policy that lets ordinary users
    # talk to the daemon, and the actions that authorize enrollment and
    # configuration changes are installed for polkit.
    machine.succeed("grep -q gaze /etc/dbus-1/system.conf")
    machine.succeed(
        "test -e /run/current-system/sw/share/polkit-1/actions/com.gundulabs.gaze.policy"
    )

    machine.succeed("command -v gaze")
    machine.succeed("command -v gaze-gui")

    # Face authentication runs before the password prompt, which stays as the
    # fallback.
    for service in ["sudo", "polkit-1"]:
        assert "pam_gaze.so" in "".join(auth_rules(service)), (
            f"{service} does not attempt face authentication"
        )
        assert auth_position(service, "pam_gaze.so") < auth_position(
            service, "pam_unix.so"
        ), f"{service} tries the password before the face"

    # The lock screen slot gates the account before scanning, because a match
    # ends the authentication stack, and it ends on a match instead of running
    # into the trailing pam_deny.
    slot = "".join(auth_rules("kde-fingerprint"))
    assert "pam_nologin.so" in slot
    assert "[success=done default=ignore]" in slot
    assert auth_position("kde-fingerprint", "pam_faillock.so preauth") < auth_position(
        "kde-fingerprint", "pam_gaze.so"
    )

    # The login stack, which the Plasma Login Manager and SDDM both substack,
    # hands the KWallet credential over right after a face match and reaches the
    # password fallback otherwise.
    assert "kde-login" in "".join(auth_rules("login"))
    assert auth_position("login", "pam_gaze.so") < auth_position(
        "login", "pam_kwallet5.so"
    ) < auth_position("login", "pam_unix.so")

    # The GNOME extension is linked into the system profile, compiled, and
    # enabled in the GDM dconf profile.
    extension = "/run/current-system/sw/share/gnome-shell/extensions/gaze@gundulabs.com"
    machine.succeed(f"test -f {extension}/extension.js")
    machine.succeed(f"test -f {extension}/schemas/gschemas.compiled")
    machine.succeed(
        "grep -qa gaze@gundulabs.com $(sed -n 's|^file-db:||p' /etc/dconf/profile/gdm)"
    )
    gdm_face = "".join(auth_rules("gdm-face"))
    assert "pam_gaze.so" in gdm_face
    assert "pam_gnome_keyring.so use_authtok" in gdm_face

    # The per-service knob wires any documented service, here the Cinnamon
    # lock screen.
    assert "pam_gaze.so" in "".join(auth_rules("cinnamon-screensaver"))
  '';
}
