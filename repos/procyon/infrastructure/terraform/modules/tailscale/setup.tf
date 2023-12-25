# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

resource "time_rotating" "rotate_monthly" {
  rotation_days = 30
}

resource "time_static" "rotate_monthly" {
  rfc3339 = time_rotating.rotate_monthly.rfc3339
}
