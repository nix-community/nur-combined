from scriptipy import *
from abc import ABCMeta, abstractmethod
import nixdata

# logging.basicConfig(level=logging.DEBUG)

api_keys: dict[str, str] = (
    run(
        nixdata.sops_bin,
        "--decrypt",
        nixdata.git_keys_json,
    )
    .json()
    .must_succeed()
)

domains: list[str] = sys.argv[1:]

for domain in domains:
    if domain not in api_keys:
        die(f"dunno {domain=}")

if len(domains) == 0:
    domains = list(api_keys.keys())


def filter_content(x: str) -> str:
    parts = x.split(" ", 2)
    return " ".join(parts[0:2])


@dataclass
class SshKey:
    id: int
    name: str
    content: str


class GitApi(metaclass=ABCMeta):
    domain: str
    api_key: str
    client: httpx.Client

    @staticmethod
    def authorization_name() -> str:
        return "Bearer"

    def _apply_client_settings(self) -> None:
        self.client.headers["authorization"] = (
            f"{self.authorization_name()} {self.api_key}"
        )

    def __init__(self, domain: str, api_key: str):
        self.domain = domain
        self.api_key = api_key
        self.client = httpx.Client()
        self._apply_client_settings()

    @abstractmethod
    def get_keys(self) -> list[SshKey]: ...

    @abstractmethod
    def add_key(self, name: str, content: str) -> None: ...

    @abstractmethod
    def remove_key(self, id_: int) -> None: ...


class RestfulApi(GitApi, metaclass=ABCMeta):
    @staticmethod
    def base_path() -> str:
        assert False

    def base_url(self) -> str:
        return f"https://{self.domain}{self.base_path()}"

    @staticmethod
    def keys_path() -> str:
        return "/user/keys"

    def keys_url(self) -> str:
        return f"{self.base_url()}{self.keys_path()}"

    def get_keys(self) -> list[SshKey]:
        resp = self.client.get(self.keys_url())
        # print(f"{resp.text=}")
        resp.raise_for_status()
        data = resp.json()
        return [
            SshKey(id=x["id"], content=filter_content(x["key"]), name=x["title"])
            for x in data
        ]

    def add_key(self, name: str, content: str) -> None:
        data = {"title": name, "key": content}
        self.client.post(self.keys_url(), json=data).raise_for_status()

    def remove_key(self, id_: int) -> None:
        self.client.delete(self.keys_url() + f"/{id_}").raise_for_status()


class GitHubApi(RestfulApi):
    def base_url(self) -> str:
        return f"https://api.{self.domain}"

    def _apply_client_settings(self) -> None:
        super()._apply_client_settings()
        self.client.headers["accept"] = "application/vnd.github+json"
        self.client.headers["X-GitHub-Api-Version"] = "2022-11-28"


class GitLabApi(RestfulApi):
    @staticmethod
    def base_path() -> str:
        return "/api/v4"


class ForgejoApi(RestfulApi):
    @staticmethod
    def base_path() -> str:
        return "/api/v1"

    @staticmethod
    def authorization_name() -> str:
        return "token"


class SourceHutApi(GitApi):
    def query(self, query: str, **variables: Any) -> Any:
        resp = self.client.post(
            f"https://meta.{domain}/query",
            json={"query": query, "variables": variables},
        )
        resp.raise_for_status()
        return resp.json()

    def get_keys(self) -> list[SshKey]:
        resp = self.query(
            "query { me { sshKeys { cursor results { id key comment } } } }"
        )
        # print(f"{resp=}")
        paged = resp["data"]["me"]["sshKeys"]
        if paged["cursor"] != None:
            die("lol u have to implement paging bitch")
        return [
            SshKey(id=x["id"], name=x["comment"], content=filter_content(x["key"]))
            for x in paged["results"]
        ]

    def add_key(self, name: str, content: str) -> None:
        self.query(
            "mutation Foo($key: String!) { createSSHKey(key: $key) { id } }",
            key=f"{content} {name}",
        )

    def remove_key(self, id_: int) -> None:
        self.query("mutation Foo($id: Int!) { deleteSSHKey(id: $id) { id } }", id=id_)


for domain in domains:
    api_key = api_keys[domain]

    api_class: type[GitApi] = {
        "github.com": GitHubApi,
        "gitlab.com": GitLabApi,
        "git.uninsane.org": ForgejoApi,
        "sr.ht": SourceHutApi,
    }[domain]

    api = api_class(domain=domain, api_key=api_key)

    print(f"## {domain}")
    print()
    # print(f"{api.client.headers=}")
    keys_on_service = api.get_keys()
    for key in keys_on_service:
        print(f"key#{key.id} ({key.name})")
        print(f"  {key.content}")
        print()

    for key_name, key_content in nixdata.current_keys.items():
        if any(
            x.name == key_name and x.content == key_content for x in keys_on_service
        ):
            continue
        print(f"Adding {key_name}")
        api.add_key(name=key_name, content=key_content)

    for key in keys_on_service:
        if any(
            key.name == k and key.content == v for k, v in nixdata.current_keys.items()
        ):
            continue
        print(f"Removing key#{key.id} {key.name}")
        api.remove_key(key.id)
