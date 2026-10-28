import json

type Value = str | int | float | None | list[Value] | dict[str, Value]
