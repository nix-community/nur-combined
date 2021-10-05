#! /usr/bin/env nix-shell
#! nix-shell -i python3
#! nix-shell -p python3Packages.numpy
#! nix-shell -p python3Packages.matplotlib

import numpy as np
import matplotlib.pyplot as plt

xs = np.linspace (-2, 2, num =100)
plt.plot(xs , np.exp(-xs **2))
plt.show()
