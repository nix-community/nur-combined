#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# 配置
# ----------------------------
STATUS_FILE="status.json"          # 来源 JSON
HTML_FILE="status.html"            # 输出 HTML
HISTORY_DAYS=30                    # 展示最近 N 天
BAR_WIDTH=12                        # 每条柱子宽度
BLOCK_HEIGHT=10                     # 每条轮询块高度
BAR_MARGIN=4                        # 柱子间距

# ----------------------------
# 清空 HTML 文件
# ----------------------------
cat > "$HTML_FILE" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
.container {
  display: flex;
  align-items: flex-end;
  font-family: sans-serif;
}
.bar-column {
  display: flex;
  flex-direction: column-reverse; /* 最新在上 */
  margin-right: ${BAR_MARGIN}px;
}
.bar-block {
  width: ${BAR_WIDTH}px;
  height: ${BLOCK_HEIGHT}px;
  margin-bottom: 1px;
}
.synced { background-color: #4caf50; }
.unsynced { background-color: #f44336; }
.bar-label {
  text-align: center;
  font-size: 10px;
  margin-top: 4px;
}
</style>
</head>
<body>
<div class="container">
EOF

# ----------------------------
# 读取历史状态，排除 initial
# ----------------------------
HISTORY=$(jq --argjson days "$HISTORY_DAYS" '
  def cutoff: (now - ($days*24*3600));
  .history
  | map(select(.phase=="polled"))
  | map(select(.timestamp|fromdateiso8601 > cutoff))
' "$STATUS_FILE")

# ----------------------------
# 按日期分组生成柱子
# ----------------------------
# 获取最近日期的升序
DATES=$(echo "$HISTORY" | jq -r '.[].timestamp[0:10]' | sort -u)

for DATE in $DATES; do
  # 获取当天的所有记录
  DAY_RECORDS=$(echo "$HISTORY" | jq --arg date "$DATE" '[.[] | select(.timestamp[0:10]==$date)]')

  # 生成柱子
  echo "<div class=\"bar-column\" title=\"$DATE\">" >> "$HTML_FILE"

  echo "$DAY_RECORDS" | jq -c '.[]' | while read -r rec; do
    STATUS=$(echo "$rec" | jq -r '.status')
    TS=$(echo "$rec" | jq -r '.timestamp')
    echo "<div class=\"bar-block $STATUS\" title=\"$TS\"></div>" >> "$HTML_FILE"
  done

  echo "</div>" >> "$HTML_FILE"
done

# ----------------------------
# 最新状态信息显示在顶部
# ----------------------------
LATEST=$(echo "$HISTORY" | jq -r '.[-1]')
LATEST_STATUS=$(echo "$LATEST" | jq -r '.status')
LATEST_FORK=$(echo "$LATEST" | jq -r '.fork_rev')
LATEST_OFFICIAL=$(echo "$LATEST" | jq -r '.official_rev')
LATEST_TS=$(echo "$LATEST" | jq -r '.timestamp')

echo "<div style=\"margin-left:20px; font-size:12px;\">Latest: $LATEST_TS | Fork: $LATEST_FORK | Official: $LATEST_OFFICIAL | Status: $LATEST_STATUS</div>" >> "$HTML_FILE"

# ----------------------------
# 结束 HTML
# ----------------------------
echo "</div></body></html>" >> "$HTML_FILE"

echo "Rendered HTML to $HTML_FILE"
