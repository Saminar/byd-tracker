---
name: 比亚迪
description: >
  比亚迪(BYD)产业链股票追踪与分析。获取上下游核心公司（A股/港股/美股）的实时行情、
  昨日收盘价、财报数据和相关新闻，生成带买卖建议的可视化分析报告，
  并同步到 GitHub knowledge-base 知识库统一管理。
  触发词：比亚迪、BYD、产业链分析、股价追踪、新能源汽车产业链、电动车股票。
description_zh: "比亚迪产业链股票追踪（行情/新闻/分析/报告）"
description_en: "BYD supply chain stock tracker (quotes/news/analysis/report)"
metadata: {"emoji":"🚗"}
visibility: private
sharing: none
---

# 🚗 比亚迪产业链追踪 Skill

追踪比亚迪（BYD）上下游 **核心上市公司** 的股票行情、新闻和财报数据，
覆盖 A 股、港股、美股三大市场，
自动生成分析报告并同步到 GitHub 知识库。

## 覆盖标的

### 核心
| 公司 | A股代码 | 港股代码 | 市场 |
|------|---------|---------|------|
| 比亚迪 | 002594 | **01211** | 深交所主板 + 港交所 |

### 上游 — 矿产资源（4家，含3只港股）
| 公司 | A股代码 | 港股代码 | 市场 | 角色 |
|------|---------|---------|------|------|
| 天齐锂业 | 002466 | **09696** | 深交所 + 港交所 | 锂盐、碳酸锂 |
| 赣锋锂业 | 002460 | **01772** | 深交所 + 港交所 | 锂化合物及金属锂 |
| 华友钴业 | 603799 | - | 上交所 | 钴材料及三元前驱体 |
| 洛阳钼业 | 603993 | **03993** | 上交所 + 港交所 | 钴、镍等资源 |

### 上游 — 核心材料（7家）
| 公司 | 代码 | 市场 | 角色 |
|------|------|------|------|
| 湖南裕能 | 301358 | 深交所创业板 | 磷酸铁锂正极材料 |
| 德方纳米 | 300769 | 深交所创业板 | 磷酸铁锂正极材料 |
| 璞泰来 | 603659 | 上交所 | 负极材料及涂覆隔膜 |
| 贝特瑞 | 835185 | 北交所 | 负极材料 |
| 恩捷股份 | 002812 | 深交所 | 锂电隔膜 |
| 天赐材料 | 002709 | 深交所 | 电解液 |
| 新宙邦 | 300037 | 深交所创业板 | 电解液 |

### 上游 — 锂电设备（3家）
| 公司 | 代码 | 市场 | 角色 |
|------|------|------|------|
| 先导智能 | 300450 | 深交所创业板 | 锂电池生产设备 |
| 赢合科技 | 300457 | 深交所创业板 | 锂电池设备 |
| 北方华创 | 002371 | 深交所 | 半导体及新能源装备 |

### 下游 — 新能源整车厂（5家，含4只港股）
| 公司 | 主代码 | 港股代码 | 市场 | 角色 |
|------|--------|---------|------|------|
| 特斯拉 | TSLA | - | 美股纳斯达克 | 全球电动车龙头 |
| 理想汽车 | LI | **02015** | 美股纳斯达克 + 港交所 | 增程式电动车 |
| 蔚来汽车 | NIO | **09866** | 美股纽交所 + 港交所 | 智能电动车 |
| 小鹏汽车 | XPEV | **09868** | 美股纽交所 + 港交所 | 智能电动车 |
| 小米集团 | - | **01810** | 港交所 | SU7系列竞品 |

### 下游 — 电子及储能（3家）
| 公司 | A股代码 | 港股代码 | 市场 | 角色 |
|------|---------|---------|------|------|
| 比亚迪电子 | - | **00285** | 港交所 | 手机部件及组装 |
| 阳光电源 | 300274 | - | 深交所创业板 | 光伏逆变器+储能 |
| 科华数据 | 002335 | - | 深交所 | 储能系统 |

## 依赖

- **Python 3.9+**
- **akshare** — 免费开源财经数据接口库

安装命令：
```bash
pip3 install akshare --upgrade
```

## 完整工作流程

```
用户触发 "分析比亚迪产业链" / "追踪BYD"
│
├─ 第1步：全景生态透视与技术竞争力分析 (⚠️ 必须执行！不可跳过！)
│   └─ 调用 `company-ecosystem-analyzer` 技能，以「比亚迪」为输入。
│   └─ 必须让该技能真实执行并输出完整的 HTML 报告内容（包含 ECharts 雷达图脚本）。
│   └─ ⚠️ 严禁 AI 自行发挥或伪造 HTML 结果，将其原样保存至 `/tmp/byd_ecosystem.html`。
│   └─ ⚠️ 在第6步生成报告前，必须验证 /tmp/byd_ecosystem.html 文件存在且非空（>1KB）。
│   └─ ⚠️ 如果此步骤失败或被跳过，最终报告的「全景透视」Tab 将显示空白。
│
├─ 第2步：安装/检查依赖
│   └─ pip3 install akshare --upgrade
│
├─ 第3步：确认标的与获取股价数据
│   └─ ⚠️ **港股确认项**：每个A股企业都要确认一遍是否有对应的港股，如果有则必须在数据获取时新增进来。
│   └─ 运行 scripts/fetch_stock_data.py --output /tmp/byd_stock.json
│
├─ 第4步：获取新闻和财报数据
│   └─ 运行 scripts/fetch_news_analysis.py --output /tmp/byd_news.json
│
├─ 第5步：AI 分析生成（由 Agent 完成）
│   └─ 基于股价、新闻与财报，判断核心公司买卖建议，输出为 /tmp/byd_analysis.json
│
├─ 第6步：生成 HTML 报告
│   └─ 运行 scripts/generate_report.sh /tmp/byd_stock.json /tmp/byd_news.json /tmp/byd_analysis.json /tmp/byd_ecosystem.html [output_dir]
│   └─ 生成的报告中，全景透视 Tab 下将完整展示第一步中真实的 mcp(skill) 输出结果。
│
├─ 第7步：同步报告到 GitHub knowledge-base（⚠️ 必须！）
│   └─ 运行 scripts/sync_report.sh <报告HTML路径> [日期]
│   └─ 自动 cp + git commit + git push 到 Saminar/knowledge-base
│
├─ 第8步：同步摘要到腾讯文档知识库（⚠️ 必须！）
│   └─ 加载 tencent-docs skill
│   └─ 在「Sami 知识管理空间」(space_id: SjiwMWMacXdA) → 行业研究目录 (node_id: SJgfwkAARTGJ) 下创建智能文档
│   └─ 文档标题格式：「BYD产业链日报 YYYY-MM-DD」
│   └─ 内容包含：市场概况 + 核心标的涨跌 + AI分析建议摘要 + 焦点事件
│
└─ 完成：展示报告链接与预览
```

## 执行步骤详解

### 步骤 1：全景生态透视与技术竞争力分析（⚠️ 必须执行！）

> **此步骤为必须步骤，不可跳过。** 如跳过，报告「全景透视」Tab 将显示空白。

调用 `company-ecosystem-analyzer` 技能，以「比亚迪」为输入。
**注意**：该技能会生成详细的生态透视和技术竞争力雷达图（HTML 格式）。你必须等待该技能完整执行完毕，提取其生成的实际 HTML 代码，保存至 `/tmp/byd_ecosystem.html`。**绝对禁止自行编造或跳过此步骤**。

**验证方法：**
```bash
# 生成后必须验证文件存在且非空
test -s /tmp/byd_ecosystem.html && echo "✅ ecosystem.html ready ($(wc -c < /tmp/byd_ecosystem.html) bytes)" || echo "❌ FAILED: ecosystem.html missing or empty"
```

### 步骤 2：检查并安装依赖

```bash
pip3 install akshare --upgrade 2>/dev/null
python3 -c "import akshare; print(f'akshare {akshare.__version__} ready')"
```

如果系统 Python 版本不够，使用 managed runtime：
```bash
cd /Users/yangyangfan/.workbuddy/binaries/node/workspace
/usr/bin/python3 -m pip install akshare --user
```

### 步骤 3：确认标的与获取股价数据

在获取数据前，务必审查一次标的列表（包含上下游），**逐一确认这些 A 股企业是否在香港发行了 H 股**。发现未涵盖的港股，须通过修改脚本或参数将其纳入。

```bash
python3 ~/.workbuddy/skills/byd-tracker/scripts/fetch_stock_data.py --output /tmp/byd_stock.json
```

输出示例（JSON）：
```json
{
  "timestamp": "2026-04-21 15:30:00",
  "total_companies": 20,
  "companies": [...],
  "quotes": {
    "002594": {
      "name": "比亚迪",
      "price": 380.50,
      "prev_close": 375.30,
      "change_pct": 1.38,
      "volume": 12345678,
      ...
    }
  }
}
```

### 步骤 4：获取新闻和财报

```bash
python3 ~/.workbuddy/skills/byd-tracker/scripts/fetch_news_analysis.py --output /tmp/byd_news.json
```

### 步骤 5：AI 分析（Agent 生成）

基于步骤 3 和步骤 4 的数据，Agent 需要生成分析 JSON，格式如下：

```json
{
  "report_date": "2026-04-21",
  "market_summary": "今日比亚迪产业链整体...",
  "analyses": [
    {
      "name": "比亚迪",
      "code": "SZ.002594",
      "signal": "buy",
      "price_info": "¥380.50 (+1.38%)",
      "reason": "基于xxx原因，当前估值合理，建议关注...",
      "key_factors": "1) 一季报营收同比增长xx% 2) 新能源汽车销量持续增长 3) PEG=0.9(低估)",
      "sources": [
        {"title": "新闻标题", "url": "https://..."},
        {"title": "财报快讯", "url": "https://..."}
      ]
    }
  ]
}
```

**signal 字段取值：**
| 值 | 含义 | 条件参考 |
|------|------|------|
| `buy` | 建议买入 | 基本面良好 + 技术面向好 + 利好消息 |
| `sell` | 建议卖出 | 基本面恶化 + 利空消息 + 高估值 |
| `hold` | 建议持有 | 基本面稳定、无明显利好利空 |
| `watch` | 观望 | 不确定性大、需要更多信息 |

**分析要点：**

1. **股价变动分析**：对比昨收和当前价格，标注涨跌幅超过 3% 的标的
2. **新闻关联分析**：将新闻内容与股价变动关联，找出因果关系
3. **产业链联动**：分析上游价格变动对下游的影响（如碳酸锂涨价→电池成本）
4. **买卖建议**：综合估值（PE）、行业趋势、短期消息面给出建议
5. **结合增长率分析（PEG指标）**：针对每支股票计算并分析 PEG（市盈率 ÷ 盈利增长率，如净利润同比增长率）。判断标准：PEG < 1 可能被低估；PEG = 1 合理估值；PEG > 1 可能被高估。
6. **参考来源**：每条分析至少附带 1-2 个新闻/数据来源链接

### 步骤 6：生成 HTML 报告

```bash
bash ~/.workbuddy/skills/byd-tracker/scripts/generate_report.sh \
  /tmp/byd_stock.json \
  /tmp/byd_news.json \
  /tmp/byd_analysis.json \
  /tmp/byd_ecosystem.html \
  /tmp
```

报告特点：
- 📊 **行情总览 Tab**：全部标的的实时行情表格，可按分类筛选
- 🧠 **分析建议 Tab**：AI 生成的买卖建议卡片，附带参考来源
- 📰 **要闻速递 Tab**：行业新闻 + 个股新闻聚合
- 🌐 **全景透视 Tab**：嵌入 company-ecosystem-analyzer 生成的深度生态分析报告
- 🌓 支持深色/浅色模式自动切换
- 📱 响应式布局，支持手机查看

### 步骤 7：同步到 GitHub knowledge-base（⚠️ 必须执行！）

> **此步骤为必须步骤，不可跳过。** 每次生成报告后都必须同步到 GitHub knowledge-base。

运行同步脚本：
```bash
bash ~/.workbuddy/skills/byd-tracker/scripts/sync_report.sh <报告HTML路径> [YYYY-MM-DD]
```

脚本自动完成：
1. 复制报告到 `knowledge-base/docs/investment/`
2. 更新 `byd_report_latest.html` 软链接
3. 更新 `index.md` 索引（含历史报告列表）
4. Git add + commit + push 到 `Saminar/knowledge-base`

### 步骤 8：同步摘要到腾讯文档知识库（⚠️ 必须执行！）

> **此步骤为必须步骤，不可跳过。** 每次生成报告后都必须在腾讯文档知识库创建摘要文档。

**操作流程：**
1. 加载 `tencent-docs` skill
2. 调用 `create_smartcanvas_by_mdx` 创建智能文档，标题格式：`BYD产业链日报 YYYY-MM-DD`
3. 内容包含：市场概况 + 核心标的涨跌表格 + AI分析建议摘要 + 焦点事件
4. 调用 `manage.move_file_to_space` 将文档移入「Sami 知识管理空间」(space_id: `SjiwMWMacXdA`) → 行业研究目录 (node_id: `SJgfwkAARTGJ`)

## 常用命令

### 完整报告生成
```
"分析比亚迪产业链" / "BYD产业链追踪" / "更新比亚迪报告"
```

### 仅查股价
```
"比亚迪产业链股价" / "BYD上下游行情"
```

### 仅看新闻
```
"比亚迪最新新闻" / "新能源汽车产业链资讯"
```

### 单独分析某公司
```
"分析天齐锂业" / "分析阳光电源"
```

## 数据源说明

| 数据类型 | 来源 | 说明 |
|---------|------|------|
| A 股实时行情 | 东方财富（via AKShare） | 交易时段实时，非交易时段为收盘价 |
| 港股实时行情 | 东方财富（via AKShare） | 同上 |
| 美股行情 | 东方财富（via AKShare） | 美股交易时段为延迟行情 |
| 个股新闻 | 东方财富（via AKShare） | 近期新闻 |
| 财务数据 | 同花顺（via AKShare） | 最新财报快报 |

## 注意事项

⚠️ **免责声明**
- 所有数据通过 AKShare 从公开渠道获取，仅供学习参考
- **不构成任何投资建议**，投资有风险，入市需谨慎
- AI 分析基于有限信息，可能存在偏差

⚠️ **数据时效性**
- A 股交易时间：周一至周五 9:30-15:00
- 港股交易时间：周一至周五 9:30-16:00
- 美股交易时间：北京时间 21:30-04:00（冬令时 22:30-05:00）
- 非交易时段获取的为最近一次收盘数据

⚠️ **API 限制**
- AKShare 免费使用，但高频调用可能被限流
- 建议每次完整运行间隔 > 5 分钟
- 如遇到超时，重试即可

## 文件结构

```
byd-tracker/
├── SKILL.md                           # 本文件
├── references/
│   └── companies.json                 # 公司代码清单（完整版）
└── scripts/
    ├── fetch_stock_data.py            # 股价数据获取器
    ├── fetch_news_analysis.py         # 新闻/财报获取器
    ├── generate_report.sh             # HTML 报告生成器
    └── sync_report.sh                 # 报告同步器（GitHub + 索引）
```
