import sys
import tkinter as tk
from pathlib import Path
from tkinter import messagebox

LIMITS = [(1, "Sustained"), (2, "Burst")]


def find_hwmon() -> Path:
    for p in sorted(Path("/sys/class/hwmon").iterdir()):
        if (p / "name").read_text().strip() == "amdgpu" and (p / "power1_cap").exists():
            return p
    sys.exit("no amdgpu hwmon with power1_cap found")


def read_w(path: Path) -> float:
    return int(path.read_text()) / 1_000_000


class App:
    def __init__(self, root: tk.Tk, hwmon: Path):
        self.hwmon = hwmon
        self.scales: dict[int, tk.Scale] = {}
        root.title("TDP Limits")

        for row, (n, name) in enumerate(LIMITS):
            label = hwmon / f"power{n}_label"
            if label.exists():
                name += f" ({label.read_text().strip()})"
            tk.Label(root, text=name).grid(row=row, column=0, sticky="w", padx=8)
            lo = read_w(hwmon / f"power{n}_cap_min")
            hi = read_w(hwmon / f"power{n}_cap_max")
            scale = tk.Scale(
                root,
                from_=max(lo, 1),
                to=hi,
                resolution=0.5,
                orient="horizontal",
                length=300,
                label="W",
                command=lambda _v, n=n: self.keep_order(n),
            )
            scale.set(read_w(hwmon / f"power{n}_cap"))
            scale.grid(row=row, column=1, padx=8, pady=4)
            self.scales[n] = scale

        self.status = tk.Label(root)
        self.status.grid(row=2, column=0, columnspan=2)

        buttons = tk.Frame(root)
        buttons.grid(row=3, column=0, columnspan=2, pady=8)
        tk.Button(buttons, text="Apply", command=self.apply).pack(side="left", padx=4)
        tk.Button(buttons, text="Defaults", command=self.defaults).pack(side="left", padx=4)

        self.root = root
        self.refresh()

    def keep_order(self, changed: int):
        sustained, burst = self.scales[1], self.scales[2]
        if sustained.get() > burst.get():
            if changed == 1:
                burst.set(sustained.get())
            else:
                sustained.set(burst.get())

    def write(self, values: dict[int, float]):
        try:
            for n, w in values.items():
                (self.hwmon / f"power{n}_cap").write_text(str(int(w * 1_000_000)))
        except OSError as e:
            messagebox.showerror("TDP Limits", str(e))

    def apply(self):
        self.write({n: s.get() for n, s in self.scales.items()})

    def defaults(self):
        values = {n: read_w(self.hwmon / f"power{n}_cap_default") for n in self.scales}
        self.write(values)
        for n, w in values.items():
            self.scales[n].set(w)

    def refresh(self):
        caps = " / ".join(f"{read_w(self.hwmon / f'power{n}_cap'):g}" for n in self.scales)
        avg = self.hwmon / "power1_average"
        if not avg.exists():
            avg = self.hwmon / "power1_input"
        draw = f"{read_w(avg):.1f} W" if avg.exists() else "?"
        self.status.config(text=f"Active caps: {caps} W    APU draw: {draw}")
        self.root.after(1000, self.refresh)


root = tk.Tk()
App(root, find_hwmon())
root.mainloop()
