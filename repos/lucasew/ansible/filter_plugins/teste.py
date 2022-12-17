from typing import Optional

def greet(name: Optional[str]):
    if name is None:
        return "Hello!"
    else:
        return f"Hello, {name}!"

class FilterModule:
    def filters(self):
        return {
            'greet': greet
        }
