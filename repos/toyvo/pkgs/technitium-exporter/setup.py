from setuptools import setup

setup(
    name="technitium-exporter",
    version="0.1.0",
    py_modules=["exporter"],
    entry_points={
        "console_scripts": [
            "technitium-exporter=exporter:main",
        ],
    },
)
