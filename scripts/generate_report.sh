#!/bin/bash
# 比亚迪产业链报告生成器
# 用法: bash generate_report.sh '<stock_json>' '<news_json>' '<analysis_json>' '<ecosystem_html>' [output_dir]
#
# stock_json    - fetch_stock_data.py 的输出
# news_json     - fetch_news_analysis.py 的输出  
# analysis_json - AI 生成的分析结论 JSON
# ecosystem_html- 全景生态透视与技术竞争力分析 HTML 片段
# output_dir    - 输出目录（默认当前目录）

STOCK_JSON_FILE="$1"
NEWS_JSON_FILE="$2"
ANALYSIS_JSON_FILE="$3"
ECOSYSTEM_HTML_FILE="$4"
OUTPUT_DIR="${5:-$(pwd)}"
REPORT_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$OUTPUT_DIR/byd_report_${REPORT_DATE}.html"

if [ -z "$STOCK_JSON_FILE" ] || [ -z "$NEWS_JSON_FILE" ] || [ -z "$ANALYSIS_JSON_FILE" ] || [ -z "$ECOSYSTEM_HTML_FILE" ]; then
    echo "用法: bash generate_report.sh <stock.json> <news.json> <analysis.json> <ecosystem.html> [output_dir]"
    exit 1
fi

STOCK_DATA=$(cat "$STOCK_JSON_FILE")
NEWS_DATA=$(cat "$NEWS_JSON_FILE")
ANALYSIS_DATA=$(cat "$ANALYSIS_JSON_FILE")

cat > "$OUTPUT_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🚗 比亚迪产业链追踪 — REPORT_DATE_PLACEHOLDER</title>
<style>
:root {
  --bg: #f8f9fb;
  --card: #ffffff;
  --border: #e8ecf1;
  --text: #1a202c;
  --text2: #64748b;
  --accent: #f59e0b;
  --green: #22c55e;
  --red: #ef4444;
  --orange: #f97316;
  --yellow: #eab308;
  --radius: 12px;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0f172a;
    --card: #1e293b;
    --border: #334155;
    --text: #f1f5f9;
    --text2: #94a3b8;
  }
}
* { margin:0; padding:0; box-sizing:border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  padding: 16px;
}
.container { max-width: 1280px; margin: 0 auto; }

/* Header */
.header {
  text-align: center;
  padding: 32px 0 24px;
}
.header h1 {
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -0.5px;
}
.header .meta {
  color: var(--text2);
  font-size: 14px;
  margin-top: 6px;
}

/* Summary Cards */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 12px;
  margin: 20px 0;
}
.summary-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px;
  text-align: center;
}
.summary-card .value {
  font-size: 28px;
  font-weight: 700;
}
.summary-card .label {
  font-size: 12px;
  color: var(--text2);
  margin-top: 4px;
}
.summary-card.up .value { color: var(--red); }
.summary-card.down .value { color: var(--green); }
.summary-card.flat .value { color: var(--text2); }

/* Section */
.section {
  margin: 28px 0 16px;
}
.section-title {
  font-size: 18px;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--accent);
  display: inline-block;
  margin-bottom: 16px;
}

/* Tab Navigation */
.tabs {
  display: flex;
  gap: 4px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}
.tab {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid var(--border);
  background: var(--card);
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.2s;
}
.tab:hover { border-color: var(--accent); }
.tab.active {
  background: var(--accent);
  color: white;
  border-color: var(--accent);
}

/* Stock Table */
.stock-table-wrap {
  overflow-x: auto;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  background: var(--card);
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
th {
  background: var(--bg);
  padding: 10px 12px;
  text-align: left;
  font-weight: 600;
  font-size: 12px;
  color: var(--text2);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
  border-bottom: 1px solid var(--border);
}
td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--border);
  white-space: nowrap;
}
tr:last-child td { border-bottom: none; }
tr:hover { background: rgba(245,158,11,0.04); }
.price { font-weight: 600; font-variant-numeric: tabular-nums; }
.up { color: var(--red); }
.down { color: var(--green); }
.tag {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}
.tag-core { background: #fef3c7; color: #92400e; }
.tag-upstream { background: #dbeafe; color: #1e40af; }
.tag-downstream { background: #d1fae5; color: #065f46; }

/* Analysis Cards */
.analysis-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 16px;
}
.analysis-card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 20px;
  transition: box-shadow 0.2s;
}
.analysis-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
}
.analysis-card h3 {
  font-size: 15px;
  margin-bottom: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.analysis-card .signal {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}
.signal-buy { background: #dcfce7; color: #166534; }
.signal-sell { background: #fee2e2; color: #991b1b; }
.signal-hold { background: #fef9c3; color: #854d0e; }
.signal-watch { background: #e0e7ff; color: #3730a3; }
.analysis-card .reason {
  font-size: 13px;
  color: var(--text2);
  margin: 8px 0;
  line-height: 1.6;
}
.analysis-card .sources {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid var(--border);
}
.analysis-card .sources a {
  display: block;
  font-size: 12px;
  color: var(--accent);
  text-decoration: none;
  margin: 3px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.analysis-card .sources a:hover { text-decoration: underline; }

/* News Section */
.news-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 12px;
}
.news-item {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px;
}
.news-item h4 {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 6px;
}
.news-item .snippet {
  font-size: 13px;
  color: var(--text2);
  margin-bottom: 8px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.news-item .news-meta {
  font-size: 11px;
  color: var(--text2);
  display: flex;
  justify-content: space-between;
}
.news-item a {
  color: var(--accent);
  text-decoration: none;
  font-size: 12px;
}

/* Disclaimer */
.disclaimer {
  margin-top: 40px;
  padding: 16px;
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  font-size: 12px;
  color: var(--text2);
  text-align: center;
}

/* Responsive */
@media (max-width: 768px) {
  .header h1 { font-size: 22px; }
  .analysis-grid { grid-template-columns: 1fr; }
  .news-list { grid-template-columns: 1fr; }
  .summary-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>🚗 比亚迪产业链追踪</h1>
    <div class="meta">REPORT_DATE_PLACEHOLDER · 数据来源：腾讯财经 · 仅供学习参考</div>
  </div>

  <!-- Summary -->
  <div class="summary-grid" id="summary-grid"></div>

  <!-- Tab Nav -->
  <div class="section">
    <div class="tabs" id="main-tabs">
      <div class="tab active" data-tab="quotes">📊 行情总览</div>
      <div class="tab" data-tab="analysis">🧠 分析建议</div>
      <div class="tab" data-tab="news">📰 要闻速递</div>
      <div class="tab" data-tab="ecosystem">🌐 全景透视</div>
    </div>
  </div>

  <!-- Quotes Panel -->
  <div id="panel-quotes">
    <div class="tabs" id="cat-tabs">
      <div class="tab active" data-cat="all">全部</div>
      <div class="tab" data-cat="core">核心</div>
      <div class="tab" data-cat="upstream_mining">矿产</div>
      <div class="tab" data-cat="upstream_material">材料</div>
      <div class="tab" data-cat="upstream_equipment">设备</div>
      <div class="tab" data-cat="downstream_auto">整车厂</div>
      <div class="tab" data-cat="downstream_electronics">电子</div>
      <div class="tab" data-cat="downstream_energy">储能</div>
    </div>
    <div class="stock-table-wrap">
      <table id="stock-table">
        <thead>
          <tr>
            <th>公司</th>
            <th>代码</th>
            <th>分类</th>
            <th>最新价</th>
            <th>昨收</th>
            <th>涨跌幅</th>
            <th>涨跌额</th>
            <th>成交量</th>
            <th>成交额</th>
            <th>换手率</th>
            <th>市盈率</th>
            <th>PEG</th>
          </tr>
        </thead>
        <tbody id="stock-tbody"></tbody>
      </table>
    </div>
  </div>

  <!-- Analysis Panel -->
  <div id="panel-analysis" style="display:none;">
    <div class="analysis-grid" id="analysis-grid"></div>
  </div>

  <!-- News Panel -->
  <div id="panel-news" style="display:none;">
    <div style="margin-top:24px;">
      <div class="section-title">行业要闻</div>
    </div>
    <div class="news-list" id="industry-news"></div>
    <div style="margin-top:24px;">
      <div class="section-title">个股新闻</div>
    </div>
    <div class="news-list" id="company-news"></div>
  </div>

  <!-- Ecosystem Panel -->
  <div id="panel-ecosystem" style="display:none;">
    ECOSYSTEM_DATA_PLACEHOLDER
  </div>

  <div class="disclaimer">
    ⚠️ 免责声明：本报告数据来自公开市场信息，通过腾讯财经获取，仅供学习和参考，不构成任何投资建议。投资有风险，入市需谨慎。
  </div>
</div>

<script>
// ============= DATA INJECTION =============
const stockData = STOCK_DATA_PLACEHOLDER;
const newsData = NEWS_DATA_PLACEHOLDER;
const analysisData = ANALYSIS_DATA_PLACEHOLDER;

// ============= CATEGORY LABELS =============
const catLabels = {
  core: '核心', upstream_mining: '矿产', upstream_material: '材料',
  upstream_equipment: '设备', downstream_auto: '整车厂', downstream_electronics: '电子', downstream_energy: '储能'
};
const catTagClass = {
  core: 'tag-core', upstream_mining: 'tag-upstream', upstream_material: 'tag-upstream',
  upstream_equipment: 'tag-upstream', downstream_auto: 'tag-downstream', downstream_electronics: 'tag-downstream', downstream_energy: 'tag-downstream'
};

// ============= RENDER SUMMARY =============
function renderSummary() {
  const quotes = stockData.quotes || {};
  const companies = stockData.companies || [];
  let upCount = 0, downCount = 0, flatCount = 0;
  let maxUp = {name:'', pct: -999}, maxDown = {name:'', pct: 999};
  
  companies.forEach(c => {
    const q = quotes[c.code];
    if (!q || q.error) return;
    const pct = q.change_pct || 0;
    if (pct > 0) upCount++;
    else if (pct < 0) downCount++;
    else flatCount++;
    if (pct > maxUp.pct) maxUp = {name: c.name, pct};
    if (pct < maxDown.pct) maxDown = {name: c.name, pct};
  });
  
  document.getElementById('summary-grid').innerHTML = `
    <div class="summary-card up"><div class="value">${upCount}</div><div class="label">上涨</div></div>
    <div class="summary-card down"><div class="value">${downCount}</div><div class="label">下跌</div></div>
    <div class="summary-card flat"><div class="value">${flatCount}</div><div class="label">持平/停牌</div></div>
    <div class="summary-card up"><div class="value">${maxUp.pct > -999 ? maxUp.pct.toFixed(2)+'%' : '-'}</div><div class="label">🔥 ${maxUp.name || '-'}</div></div>
    <div class="summary-card down"><div class="value">${maxDown.pct < 999 ? maxDown.pct.toFixed(2)+'%' : '-'}</div><div class="label">📉 ${maxDown.name || '-'}</div></div>
    <div class="summary-card"><div class="value">${companies.length}</div><div class="label">追踪标的</div></div>
  `;
}

// ============= RENDER TABLE =============
function renderTable(catFilter) {
  const quotes = stockData.quotes || {};
  const companies = stockData.companies || [];
  const tbody = document.getElementById('stock-tbody');
  
  const filtered = catFilter === 'all' ? companies : companies.filter(c => c.category === catFilter);
  
  tbody.innerHTML = filtered.map(c => {
    const q = quotes[c.code];
    if (!q || q.error) {
      return `<tr><td>${c.name}</td><td>${c.code}</td><td><span class="tag ${catTagClass[c.category] || ''}">${catLabels[c.category] || c.category}</span></td><td colspan="8" style="color:var(--text2)">暂无数据</td></tr>`;
    }
    const pctClass = q.change_pct > 0 ? 'up' : q.change_pct < 0 ? 'down' : '';
    const sign = q.change_pct > 0 ? '+' : '';
    const mktUnit = c.market === 'US' ? '$' : c.market === 'HK' ? 'HK$' : '¥';
    const fmtVol = q.volume > 1e8 ? (q.volume/1e8).toFixed(2)+'亿' : q.volume > 1e4 ? (q.volume/1e4).toFixed(0)+'万' : q.volume.toFixed(0);
    const fmtAmt = q.amount > 1e8 ? (q.amount/1e8).toFixed(2)+'亿' : q.amount > 1e4 ? (q.amount/1e4).toFixed(0)+'万' : q.amount.toFixed(0);
    
    // 计算 PEG
    let pegStr = '-';
    let pegColor = '';
    if (q.pe && newsData && newsData.financials && newsData.financials[c.code]) {
      const fin = newsData.financials[c.code].data || {};
      const growthStr = fin['净利润同比增长率'] || '';
      const growth = parseFloat(growthStr);
      if (!isNaN(growth) && growth > 0) {
        const peg = q.pe / growth;
        pegStr = peg.toFixed(2);
        if (peg < 1) pegColor = 'var(--green)'; // 低估
        else if (peg > 1.5) pegColor = 'var(--red)'; // 明显高估
      } else if (growth <= 0) {
        pegStr = 'N/A'; // 负增长或零增长无法计算有效PEG
      }
    }
    
    return `<tr>
      <td><strong>${c.name}</strong><br><small style="color:var(--text2)">${c.name_en}</small></td>
      <td>${c.market}.${c.code}</td>
      <td><span class="tag ${catTagClass[c.category] || ''}">${catLabels[c.category] || ''}</span></td>
      <td class="price ${pctClass}">${mktUnit}${q.price.toFixed(2)}</td>
      <td>${mktUnit}${q.prev_close.toFixed(2)}</td>
      <td class="${pctClass}" style="font-weight:600">${sign}${q.change_pct.toFixed(2)}%</td>
      <td class="${pctClass}">${sign}${q.change_amt.toFixed(2)}</td>
      <td>${fmtVol}</td>
      <td>${fmtAmt}</td>
      <td>${q.turn_over ? q.turn_over.toFixed(2)+'%' : '-'}</td>
      <td>${q.pe ? q.pe.toFixed(1) : '-'}</td>
      <td style="color:${pegColor}; font-weight:600;">${pegStr}</td>
    </tr>`;
  }).join('');
}

// ============= RENDER ANALYSIS =============
function renderAnalysis() {
  const grid = document.getElementById('analysis-grid');
  const items = analysisData.analyses || [];
  
  if (items.length === 0) {
    grid.innerHTML = '<p style="color:var(--text2);padding:20px;">暂无分析数据</p>';
    return;
  }
  
  const signalClass = {buy:'signal-buy', sell:'signal-sell', hold:'signal-hold', watch:'signal-watch'};
  const signalText = {buy:'📈 建议买入', sell:'📉 建议卖出', hold:'✋ 建议持有', watch:'👀 观望'};
  
  grid.innerHTML = items.map(a => `
    <div class="analysis-card">
      <h3>
        <span>${a.name || ''}</span>
        <span class="signal ${signalClass[a.signal] || 'signal-watch'}">${signalText[a.signal] || a.signal || ''}</span>
      </h3>
      <div style="font-size:13px;color:var(--text2);">${a.code || ''} · ${a.price_info || ''}</div>
      <div class="reason">${a.reason || ''}</div>
      ${a.key_factors ? `<div style="margin:8px 0;font-size:13px;"><strong>关键因素：</strong>${a.key_factors}</div>` : ''}
      ${a.sources && a.sources.length ? `
        <div class="sources">
          <div style="font-size:11px;color:var(--text2);margin-bottom:4px;">📎 参考来源：</div>
          ${a.sources.map(s => `<a href="${s.url || '#'}" target="_blank">${s.title || s.url || ''}</a>`).join('')}
        </div>
      ` : ''}
    </div>
  `).join('');
}

// ============= RENDER NEWS =============
function renderNews() {
  // Industry
  const iNews = newsData.industry_news || [];
  document.getElementById('industry-news').innerHTML = iNews.length ? iNews.map(n => `
    <div class="news-item">
      <h4>${n.title || ''}</h4>
      <div class="snippet">${n.content || ''}</div>
      <div class="news-meta">
        <span>${n.source || ''} · ${n.time || ''}</span>
        ${n.url ? `<a href="${n.url}" target="_blank">查看原文 →</a>` : ''}
      </div>
    </div>
  `).join('') : '<p style="color:var(--text2)">暂无行业新闻</p>';
  
  // Company
  const cNews = newsData.company_news || {};
  const allCompanyNews = [];
  Object.entries(cNews).forEach(([code, data]) => {
    (data.news || []).forEach(n => allCompanyNews.push({...n, company: data.name}));
  });
  allCompanyNews.sort((a, b) => (b.time || '').localeCompare(a.time || ''));
  
  document.getElementById('company-news').innerHTML = allCompanyNews.length ? allCompanyNews.slice(0, 30).map(n => `
    <div class="news-item">
      <h4><span class="tag tag-core" style="font-size:11px;margin-right:4px;">${n.company}</span> ${n.title || ''}</h4>
      <div class="snippet">${n.content || ''}</div>
      <div class="news-meta">
        <span>${n.source || ''} · ${n.time || ''}</span>
        ${n.url ? `<a href="${n.url}" target="_blank">查看原文 →</a>` : ''}
      </div>
    </div>
  `).join('') : '<p style="color:var(--text2)">暂无个股新闻</p>';
}

// ============= TAB SWITCHING =============
document.getElementById('main-tabs').addEventListener('click', e => {
  const tab = e.target.closest('.tab');
  if (!tab) return;
  document.querySelectorAll('#main-tabs .tab').forEach(t => t.classList.remove('active'));
  tab.classList.add('active');
  const name = tab.dataset.tab;
  ['quotes','analysis','news','ecosystem'].forEach(p => {
    document.getElementById('panel-'+p).style.display = p === name ? '' : 'none';
  });
});

document.getElementById('cat-tabs').addEventListener('click', e => {
  const tab = e.target.closest('.tab');
  if (!tab) return;
  document.querySelectorAll('#cat-tabs .tab').forEach(t => t.classList.remove('active'));
  tab.classList.add('active');
  renderTable(tab.dataset.cat);
});

// ============= INIT =============
renderSummary();
renderTable('all');
renderAnalysis();
renderNews();
</script>
</body>
</html>
HTMLEOF

# Inject data
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i '' "s|REPORT_DATE_PLACEHOLDER|$REPORT_DATE|g" "$OUTPUT_FILE"
    
    # Use Python for reliable JSON injection with validation
    python3 -c "
import sys, json

# Default fallback structures when input is empty or invalid
DEFAULTS = {
    'stock': '{\"timestamp\":\"\",\"date\":\"\",\"source\":\"\",\"total_companies\":0,\"companies\":[],\"quotes\":{}}',
    'news': '{\"industry_news\":[],\"company_news\":{}}',
    'analysis': '{\"report_date\":\"\",\"market_summary\":\"\",\"analyses\":[]}'
}

def sanitize_json(raw, fallback_key=None):
    \"\"\"Parse and re-serialize JSON to ensure valid JS-safe output.\"\"\"
    raw = (raw or '').strip()
    if not raw:
        return DEFAULTS.get(fallback_key, '{}')
    try:
        obj = json.loads(raw)
        return json.dumps(obj, ensure_ascii=False)
    except json.JSONDecodeError:
        # Attempt to fix common issues: curly/smart quotes inside strings
        fixed = raw.replace('\u201c', '\u300c').replace('\u201d', '\u300d')
        fixed = fixed.replace('\u2018', '\u300e').replace('\u2019', '\u300f')
        try:
            obj = json.loads(fixed)
            return json.dumps(obj, ensure_ascii=False)
        except:
            # Return a safe fallback instead of broken JSON
            return DEFAULTS.get(fallback_key, '{}')

with open('$OUTPUT_FILE', 'r') as f:
    content = f.read()
with open('$STOCK_JSON_FILE', 'r') as f:
    stock = sanitize_json(f.read(), 'stock')
with open('$NEWS_JSON_FILE', 'r') as f:
    news = sanitize_json(f.read(), 'news')
with open('$ANALYSIS_JSON_FILE', 'r') as f:
    analysis = sanitize_json(f.read(), 'analysis')
try:
    with open('$ECOSYSTEM_HTML_FILE', 'r') as f:
        ecosystem = f.read()
except:
    ecosystem = '<p style=\"color:var(--text2);padding:20px;\">暂无全景分析数据</p>'

content = content.replace('STOCK_DATA_PLACEHOLDER', stock, 1)
content = content.replace('NEWS_DATA_PLACEHOLDER', news, 1)
content = content.replace('ANALYSIS_DATA_PLACEHOLDER', analysis, 1)
content = content.replace('ECOSYSTEM_DATA_PLACEHOLDER', ecosystem, 1)
with open('$OUTPUT_FILE', 'w') as f:
    f.write(content)
"
else
    sed -i "s|REPORT_DATE_PLACEHOLDER|$REPORT_DATE|g" "$OUTPUT_FILE"
    python3 -c "
import sys, json

DEFAULTS = {
    'stock': '{\"timestamp\":\"\",\"date\":\"\",\"source\":\"\",\"total_companies\":0,\"companies\":[],\"quotes\":{}}',
    'news': '{\"industry_news\":[],\"company_news\":{}}',
    'analysis': '{\"report_date\":\"\",\"market_summary\":\"\",\"analyses\":[]}'
}

def sanitize_json(raw, fallback_key=None):
    raw = (raw or '').strip()
    if not raw:
        return DEFAULTS.get(fallback_key, '{}')
    try:
        obj = json.loads(raw)
        return json.dumps(obj, ensure_ascii=False)
    except json.JSONDecodeError:
        fixed = raw.replace('\u201c', '\u300c').replace('\u201d', '\u300d')
        fixed = fixed.replace('\u2018', '\u300e').replace('\u2019', '\u300f')
        try:
            obj = json.loads(fixed)
            return json.dumps(obj, ensure_ascii=False)
        except:
            return DEFAULTS.get(fallback_key, '{}')

with open('$OUTPUT_FILE', 'r') as f:
    content = f.read()
with open('$STOCK_JSON_FILE', 'r') as f:
    stock = sanitize_json(f.read(), 'stock')
with open('$NEWS_JSON_FILE', 'r') as f:
    news = sanitize_json(f.read(), 'news')
with open('$ANALYSIS_JSON_FILE', 'r') as f:
    analysis = sanitize_json(f.read(), 'analysis')
try:
    with open('$ECOSYSTEM_HTML_FILE', 'r') as f:
        ecosystem = f.read()
except:
    ecosystem = '<p style=\"color:var(--text2);padding:20px;\">暂无全景分析数据</p>'

content = content.replace('STOCK_DATA_PLACEHOLDER', stock, 1)
content = content.replace('NEWS_DATA_PLACEHOLDER', news, 1)
content = content.replace('ANALYSIS_DATA_PLACEHOLDER', analysis, 1)
content = content.replace('ECOSYSTEM_DATA_PLACEHOLDER', ecosystem, 1)
with open('$OUTPUT_FILE', 'w') as f:
    f.write(content)
"
fi

echo "✅ 报告已生成: $OUTPUT_FILE"

# Auto open
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$OUTPUT_FILE" 2>/dev/null || echo "请手动打开: $OUTPUT_FILE"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$OUTPUT_FILE" 2>/dev/null || echo "请手动打开: $OUTPUT_FILE"
else
    echo "请手动打开: $OUTPUT_FILE"
fi
