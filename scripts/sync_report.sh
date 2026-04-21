#!/bin/bash
# 比亚迪产业链报告同步到 GitHub knowledge-base
# 用法: bash sync_report.sh <报告HTML路径> [YYYY-MM-DD]

REPORT_FILE="$1"
REPORT_DATE="${2:-$(date +%Y-%m-%d)}"
KNOWLEDGE_BASE_DIR="$HOME/knowledge-base"
TARGET_DIR="$KNOWLEDGE_BASE_DIR/docs/investment"
INDEX_FILE="$TARGET_DIR/byd_index.md"
LATEST_LINK="$TARGET_DIR/byd_report_latest.html"

if [ -z "$REPORT_FILE" ] || [ ! -f "$REPORT_FILE" ]; then
    echo "用法: bash sync_report.sh <报告HTML路径> [YYYY-MM-DD]"
    echo "错误: 报告文件不存在: $REPORT_FILE"
    exit 1
fi

echo "🚗 比亚迪产业链 — 同步报告到 GitHub"
echo "📅 日期: $REPORT_DATE"
echo "📁 报告文件: $REPORT_FILE"
echo ""

# 检查 knowledge-base 目录
if [ ! -d "$KNOWLEDGE_BASE_DIR" ]; then
    echo "⚠️  knowledge-base 目录不存在，尝试克隆..."
    cd "$HOME" || exit 1
    git clone https://github.com/Saminar/knowledge-base.git
    if [ ! -d "$KNOWLEDGE_BASE_DIR" ]; then
        echo "❌ 克隆失败，请手动克隆 knowledge-base 仓库"
        exit 1
    fi
fi

# 确保目标目录存在
mkdir -p "$TARGET_DIR"

# 复制报告文件
REPORT_FILENAME="byd_report_${REPORT_DATE}.html"
TARGET_FILE="$TARGET_DIR/$REPORT_FILENAME"
cp "$REPORT_FILE" "$TARGET_FILE"
echo "✅ 报告已复制到: $TARGET_FILE"

# 更新软链接
rm -f "$LATEST_LINK"
ln -s "$REPORT_FILENAME" "$LATEST_LINK"
echo "✅ 更新最新报告链接: byd_report_latest.html -> $REPORT_FILENAME"

# 更新索引文件
if [ ! -f "$INDEX_FILE" ]; then
    cat > "$INDEX_FILE" << 'EOF'
# 比亚迪产业链追踪报告索引

本目录包含比亚迪产业链分析报告，按日期组织。

## 最新报告

[byd_report_latest.html](byd_report_latest.html) - 最新报告

## 历史报告

EOF
fi

# 检查是否已存在当天条目
if grep -q "$REPORT_FILENAME" "$INDEX_FILE"; then
    echo "⚠️  索引中已存在今日报告条目"
else
    # 在 "## 历史报告" 行后插入新条目
    sed -i.bak "/## 历史报告/a - [$REPORT_DATE]($REPORT_FILENAME) - 比亚迪产业链分析报告" "$INDEX_FILE"
    rm -f "$INDEX_FILE.bak"
    echo "✅ 索引已更新: $INDEX_FILE"
fi

# Git 操作
cd "$KNOWLEDGE_BASE_DIR" || exit 1

git add "$TARGET_DIR/"
git commit -m "🚗 更新比亚迪产业链报告 $REPORT_DATE"
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 报告已成功同步到 GitHub!"
    echo "📎 仓库: https://github.com/Saminar/knowledge-base"
    echo "📁 路径: docs/investment/$REPORT_FILENAME"
else
    echo ""
    echo "⚠️  Git 同步失败，请手动检查"
    echo "   1. cd $KNOWLEDGE_BASE_DIR"
    echo "   2. git status"
    echo "   3. git push origin main"
fi
