from setuptools import setup

setup(
    name="network-inventory",
    version="0.1.0",
    py_modules=["inventory"],
    entry_points={
        "console_scripts": [
            "network-inventory=inventory:main",
        ],
    },
)
