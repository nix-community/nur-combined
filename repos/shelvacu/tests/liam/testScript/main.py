import contextlib
import time
from typing import TYPE_CHECKING, Any, TypedDict, Self, Generator

DATA_JSON = """
@data@
"""

if TYPE_CHECKING:
    from hints import *  # type: ignore

import json
import shlex
import uuid

DATA = json.loads(DATA_JSON)
relay_ip = DATA["relayIP"]
liam_ip = DATA["liamIP"]
start_all()
liam.succeed(DATA["checkSieve"])
ns.wait_for_unit("bind.service")
ns.wait_for_open_port(53)
liam.wait_for_unit("nginx.service")
liam.wait_for_open_port(80)

liam.copy_from_host(DATA["acmeTest"], DATA["acmeTestDest"])
# liam.wait_for_unit("network-online.target")
checker.wait_for_unit("network.target")
checker.succeed("wget http://liam.dis8.net/.well-known/acme-challenge/test")

liam.wait_for_unit("postfix.service")
liam.wait_for_unit("dovecot2.service")
liam.succeed("doveadm mailbox create -u shelvacu testFolder")
relay.wait_for_unit("mailpit.service")

# generate and exchange keys so they can talk to eachother
rsyncnet.wait_for_open_port(22)
liam.succeed("systemctl start auto-borg-gen-key.service")
liam_autoborger_key = liam.succeed("cat /var/lib/auto-borg/id_ed25519.pub").strip()
rsyncnet.succeed("install -d --owner=fm2382 --mode=u=rwx /home/fm2382/.ssh")
rsyncnet.succeed(
    f"install --owner=fm2382 --mode=u=rw -T <(printf '%s' 'command=\"borg14 serve --restrict-to-repository /home/fm2382/borg-repos/liam-backup --append-only\",restrict {liam_autoborger_key}') /home/fm2382/.ssh/authorized_keys"
)
rsyncnet.succeed("sudo -u fm2382 borg-init")
liam.succeed("systemctl start auto-borg.service")
# liam.wait_for_unit("auto-borg.service")


class ImapMessage(TypedDict):
    folder: str
    flags: list[str]
    body: str


class ImapResult(TypedDict):
    result: bool
    messages: list[ImapMessage]


def make_command(args: list) -> str:
    return " ".join(map(shlex.quote, (map(str, args))))


Arg = str | bool | int

Args = dict[str, Arg]


def dict_args_to_list(dict_args: Args) -> list[str]:
    args: list[str] = []
    for k, v in dict_args.items():
        dashed = k.replace("_", "-")
        if isinstance(v, int) and not isinstance(v, bool):
            v = str(v)
        if isinstance(v, str) or (isinstance(v, bool) and v):
            args.append(f"--{dashed}")
            if isinstance(v, str):
                args.append(v)
    return args


class LogEntry(TypedDict):
    __CURSOR: str
    _SYSTEMD_UNIT: str
    MESSAGE: str
    pass


DEFAULT_JOURNALCTL_OPTS: Args = {
    "all": True,
    "output": "json",
}

# --json
# formats entries as JSON objects, separated by newline characters (see Journal JSON Format[4] for more information). Field values are generally encoded as JSON strings, with three exceptions:
#
# 1. Fields larger than 4096 bytes are encoded as null values. (This may be turned off by passing --all, but be aware that this may allocate overly long JSON objects.)
#
# 2. Journal entries permit non-unique fields within the same log entry. JSON does not allow non-unique fields within objects. Due to this, if a non-unique field is encountered a JSON array is used as field value, listing all field values as elements.
#
# 3. Fields containing non-printable or non-UTF8 bytes are encoded as arrays containing the raw bytes individually formatted as unsigned numbers.


def journalctl_log_entries(
    machine: Machine = liam, **kwargs: Arg
) -> Generator[LogEntry, None, None]:
    with_defaults = {**kwargs, **DEFAULT_JOURNALCTL_OPTS}
    args = ["journalctl", *dict_args_to_list(with_defaults)]
    status, output = machine.execute(make_command(args))
    if status != 0:
        machine.log(f"output: {output}")
        raise Exception(f"command `{args}` failed (exit code {status})")
    for line in output.splitlines():
        data: LogEntry = json.loads(line)
        assert isinstance(data, dict)
        for _, v in data.items():
            assert isinstance(v, str)
        yield data


class ProcessingWaiter(contextlib.AbstractContextManager):
    cursor: str = ""
    timeout: int = 60
    _postfix_smtpd_connections: set[str] = set()
    _postfix_queue: set[str] = set()

    def __init__(self, timeout=60):
        most_recent_entry = list(journalctl_log_entries(lines=1))[0]
        self.cursor = most_recent_entry["__CURSOR"]
        self.timeout = timeout

    def wait_until_finished(self):
        while True:
            for log_entry in journalctl_log_entries(after_cursor=self.cursor):
                self.cursor = log_entry["__CURSOR"]
                unit = log_entry["_SYSTEMD_UNIT"]
                message = log_entry["MESSAGE"]
                assert message is not None
                sl_ident = log_entry.get("SYSLOG_IDENTIFIER")
                sl_pid = log_entry.get("SYSLOG_PID")
                if unit == "postfix.service" and sl_ident == "postfix/smtpd":
                    assert sl_pid is not None
                    if message.startswith("connect from"):
                        self._postfix_smtpd_connections.add(sl_pid)
                    if message.startswith("disconnect from") or message.startswith(
                        "lost connection"
                    ):
                        self._postfix_smtpd_connections.discard(sl_pid)
                if unit == "postfix.service" and sl_ident == "postfix/qmgr":
                    queue_id = message.split(":")[0]
                    if message.endswith("(queue active)"):
                        self._postfix_queue.add(queue_id)
                    if message.endswith("removed"):
                        self._postfix_queue.discard(queue_id)
            if (
                len(self._postfix_smtpd_connections) == 0
                and len(self._postfix_queue) == 0
            ):
                return
            else:
                time.sleep(0.1)

    def __exit__(self, _a, _b, _c):
        self.wait_until_finished()


class TesterThing:
    uuid: str = ""
    default_smtp: Args = {}
    default_imap: Args = {}
    default_mailpit: Args = {}

    def __init__(
        self, smtp: Args = {}, imap: Args = {}, mailpit: Args = {}, **common: Arg
    ):
        self.uuid = str(uuid.uuid4())
        self.default_smtp = {
            "rcptto": "someone@example.com",
            "host": f"{liam_ip}",
            **common,
            **smtp,
        }
        self.default_imap = {"host": f"{liam_ip}", **common, **imap}
        self.default_mailpit = {"mailpit-url": f"http://{relay_ip}:8025", **mailpit}

    def run_expecting_json(self, name: str, **kwargs: Arg) -> dict[str, Any]:
        args: list[str] = [name, *dict_args_to_list(kwargs)]
        print(f"running {args!r}")
        with ProcessingWaiter():
            res = checker.succeed(make_command(args))
        res = res.strip()
        assert res != ""
        return json.loads(res)

    def run_smtp(self, **kwargs: Arg) -> bool:
        args = {"message_magic": self.uuid, **self.default_smtp, **kwargs}
        res = self.run_expecting_json("mailtest-smtp", **args)
        return res["result"]

    def smtp_accepted(self, **kwargs: Arg) -> Self:
        res = self.run_smtp(**kwargs)
        assert res, "Message was not accepted when it should have been"
        return self

    def smtp_rejected(self, **kwargs: Arg) -> Self:
        res = self.run_smtp(**kwargs)
        assert not res, "Message was accepted when it was supposed to be rejected"
        return self

    def run_imap(self, **kwargs: Arg) -> ImapResult:
        args = {"message_magic": self.uuid, **self.default_imap, **kwargs}
        res_unty = self.run_expecting_json("mailtest-imap", **args)
        res_ty: ImapResult = res_unty  # type: ignore
        return res_ty

    def imap_expect(
        self, mailbox: str | None = None, flags: list[str] = [], **kwargs: Arg
    ) -> Self:
        res = self.run_imap(**kwargs)
        assert res["result"]
        assert len(res["messages"]) == 1
        message = res["messages"][0]
        if mailbox is not None:
            assert message["folder"] == mailbox
        for flag in flags:
            assert flag in message["flags"]
        return self

    def imap_found(self, **kwargs: Arg) -> Self:
        return self.imap_expect(mailbox=None, flags=[], **kwargs)

    def imap_found_in(self, mailbox: str, **kwargs: Arg) -> Self:
        return self.imap_expect(mailbox=mailbox, flags=[], **kwargs)

    def imap_move_to(self, dest: str, **kwargs: Arg) -> Self:
        res = self.run_imap(move_to=dest, **kwargs)
        assert res["result"]
        return self

    def run_mailpit(self, **kwargs: Arg) -> bool:
        args = {"message_magic": self.uuid, **self.default_mailpit, **kwargs}
        res = self.run_expecting_json("mailtest-mailpit", **args)
        return res["found_message"]

    def mailpit_not_received(self, **kwargs: Arg) -> Self:
        received = self.run_mailpit(**kwargs)
        assert not received, "Expected that mail wasn't received, but it was!"
        return self

    def mailpit_received(self, **kwargs: Arg) -> Self:
        received = self.run_mailpit(**kwargs)
        assert received, "Mail was not received when it was supposed to be."
        return self


class Defaults:
    default_smtp: Args = {}
    default_imap: Args = {}
    default_mailpit: Args = {}

    def __init__(
        self, smtp: Args = {}, imap: Args = {}, mailpit: Args = {}, **common: str | bool
    ):
        self.default_smtp = {**common, **smtp}
        self.default_imap = {**common, **imap}
        self.default_mailpit = {**mailpit}

    def make_tester(
        self, smtp: Args = {}, imap: Args = {}, mailpit: Args = {}, **common: str | bool
    ) -> TesterThing:
        return TesterThing(
            smtp={**self.default_smtp, **common, **smtp},
            imap={**self.default_imap, **common, **imap},
            mailpit={**self.default_mailpit, **common, **mailpit},
        )


# The order of these shouldn't matter, other than what fails first. Whatever is at the top is probably whatever I was working on most recently.
d = Defaults(
    smtp={"submission": True, "rcptto": "someone@example.com"}, username="vacustore"
)
d.make_tester(smtp={"mailfrom": "robot@vacu.store"}).smtp_accepted().mailpit_received()
d.make_tester(smtp={"mailfrom": "foobar@vacu.store"}).smtp_rejected()
d.make_tester(smtp={"mailfrom": "abc@shelvacu.com"}).smtp_rejected()

d = Defaults(
    smtp={"mailfrom": "whoeve2@example.com", "rcptto": "sieve2est@shelvacu.com"},
    username="shelvacu",
)
# test refilter
d.make_tester().smtp_accepted().imap_move_to("MagicRefilter").imap_found_in("B")
# refilter doesnt activate on other folders
d.make_tester().smtp_accepted().imap_move_to("testFolder").imap_found_in("testFolder")
d.make_tester().smtp_accepted().imap_move_to("INBOX").imap_found_in("INBOX")
# test the sieve script is working
d.make_tester().smtp_accepted().imap_found_in("B")
# refilter doesnt activate on julie's
d.make_tester(username="julie").smtp_accepted(rcptto="julie@shelvacu.com").imap_move_to(
    "MagicRefilter"
).imap_found_in("MagicRefilter")

d = Defaults(username="shelvacu")
d.make_tester().smtp_accepted(
    mailfrom="asshole-spammer@example.com",
    rcptto="whatever@shelvacu.com",
    header="List-unsubscribe: whatever",
).imap_expect(mailbox="C", flags=["spamish-by-headers"])
d.make_tester().smtp_accepted(
    mailfrom="shipment-tracking@amazon.com",
    rcptto="amznbsns@shelvacu.com",
    subject="Your Amazon.com order has shipped (#123-1234)",
).imap_expect(mailbox="C", flags=["amazon-ignore"])

TesterThing().smtp_accepted(
    rcptto="shelvacu@shelvacu.com", username="shelvacu", smtp_starttls=True
)

d = Defaults(
    smtp={"submission": True, "rcptto": "foo@example.com"}, username="shelvacu"
)
d.make_tester().smtp_accepted(mailfrom="me@shelvacu.com").mailpit_received()
d.make_tester().smtp_accepted(mailfrom="me@dis8.net").mailpit_received()

# julie's emails should NOT get sieve'd like mine
d = Defaults(username="julie")
d.make_tester().smtp_accepted(rcptto="julie@shelvacu.com").imap_found_in("INBOX")
d.make_tester().smtp_accepted(rcptto="julie+stuff@shelvacu.com").imap_found_in("INBOX")

# mail gets given to the right user
d = Defaults(username="shelvacu")
d.make_tester().smtp_accepted(rcptto="shelvacu@shelvacu.com").imap_found()
d.make_tester().smtp_accepted(rcptto="foobar@shelvacu.com").imap_found()
d.make_tester().smtp_accepted(rcptto="roboman@vacu.store").imap_found()
d = Defaults(username="julie")
d.make_tester().smtp_accepted(rcptto="julie@shelvacu.com").imap_found()
d.make_tester().smtp_accepted(rcptto="sales@theviolincase.com").imap_found()
d.make_tester().smtp_accepted(rcptto="superwow@theviolincase.com").imap_found()

# incoming mail cant be from known domains
TesterThing().smtp_rejected(mailfrom="bob@vacu.store")
TesterThing().smtp_rejected(mailfrom="shelvacu@shelvacu.com")
TesterThing().smtp_rejected(mailfrom="julie@shelvacu.com")
TesterThing().smtp_rejected(mailfrom="@vacu.store")

TesterThing().smtp_rejected(mailfrom="reject-spam-test@example.com")

# people cant send as the wrong person
d = Defaults(smtp={"submission": True})
d.make_tester().smtp_rejected(mailfrom="julie@shelvacu.com", username="shelvacu")
d.make_tester().smtp_rejected(mailfrom="fubar@theviolincase.com", username="shelvacu")
d.make_tester().smtp_rejected(mailfrom="fubar@vacu.store", username="julie")

d = Defaults(smtp={"submission": True, "rcptto": "foo@example.com"})
d.make_tester().smtp_accepted(mailfrom="shelvacu@shelvacu.com", username="shelvacu")
d.make_tester().smtp_accepted(
    mailfrom="shelvacu@shelvacu.com",
    username="shelvacu@shelvacu.com",
    password="shelvacu",
)
d.make_tester().smtp_accepted(mailfrom="foo@vacu.store", username="shelvacu")
d.make_tester().smtp_accepted(
    mailfrom="foo@vacu.store", username="shelvacu@shelvacu.com", password="shelvacu"
)
d.make_tester().smtp_accepted(mailfrom="foo@violingifts.com", username="julie")
d.make_tester().smtp_accepted(
    mailfrom="foo@violingifts.com", username="julie@shelvacu.com", password="julie"
)

# now that there's a bunch of mail and logs and stuff, we can still run a borg backup, right?
liam.succeed("systemctl start auto-borg.service")
