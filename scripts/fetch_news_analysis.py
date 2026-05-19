#!/usr/bin/env python3
"""
比亚迪产业链 — 新闻和财报数据获取（AKShare版）
获取行业新闻、个股新闻和财务数据
"""

import json
import sys
import time
try:
    import akshare as ak
    AKSHARE_AVAILABLE = True
except ImportError:
    AKSHARE_AVAILABLE = False

from datetime import datetime, timedelta

# 产业链公司列表（用于新闻搜索）
COMPANIES = [
    "比亚迪", "天齐锂业", "赣锋锂业", "华友钴业", "洛阳钼业",
    "湖南裕能", "德方纳米", "璞泰来", "贝特瑞", "恩捷股份",
    "天赐材料", "新宙邦", "先导智能", "赢合科技", "北方华创",
    "特斯拉", "理想汽车", "蔚来汽车", "小鹏汽车", "小米集团",
    "比亚迪电子", "阳光电源", "科华数据"
]

def fetch_industry_news():
    """获取新能源汽车行业新闻"""
    if not AKSHARE_AVAILABLE:
        return []
    
    print("  📰 获取新能源汽车行业新闻...", file=sys.stderr)
    news_list = []
    
    try:
        # 获取新能源汽车行业新闻
        df = ak.stock_news_em(symbol="新能源汽车")
        if df is not None and not df.empty:
            for _, row in df.head(20).iterrows():
                news_list.append({
                    "title": str(row.get('新闻标题', '')),
                    "content": str(row.get('新闻内容', ''))[:200],
                    "source": "东方财富",
                    "time": str(row.get('发布时间', '')),
                    "url": str(row.get('新闻链接', ''))
                })
        print(f"    ✅ 获取到 {len(news_list)} 条行业新闻", file=sys.stderr)
    except Exception as e:
        print(f"    ⚠️ 行业新闻获取失败: {e}", file=sys.stderr)
    
    return news_list

def fetch_company_news(company_name):
    """获取单个公司的新闻"""
    if not AKSHARE_AVAILABLE:
        return []
    
    try:
        df = ak.stock_news_em(symbol=company_name)
        if df is not None and not df.empty:
            news = []
            for _, row in df.head(5).iterrows():
                news.append({
                    "title": str(row.get('新闻标题', '')),
                    "content": str(row.get('新闻内容', ''))[:150],
                    "source": "东方财富",
                    "time": str(row.get('发布时间', '')),
                    "url": str(row.get('新闻链接', ''))
                })
            return news
    except Exception:
        pass
    return []

def fetch_financial_data(stock_code):
    """获取财务数据（用于PEG计算）"""
    if not AKSHARE_AVAILABLE:
        return {}
    
    try:
        # 获取主要财务指标
        df = ak.stock_financial_abstract_ths(symbol=stock_code, indicator="按报告期")
        if df is not None and not df.empty:
            # 查找净利润同比增长率
            for _, row in df.iterrows():
                if '净利润' in str(row.get('指标', '')) and '同比' in str(row.get('指标', '')):
                    latest = row.get('2024-09-30', row.get('2024-06-30', ''))
                    if latest:
                        return {"净利润同比增长率": str(latest)}
    except Exception:
        pass
    return {}

def main():
    print("🚗 比亚迪产业链 — 新闻和财报数据获取", file=sys.stderr)
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", file=sys.stderr)
    
    if not AKSHARE_AVAILABLE:
        print("⚠️ akshare 未安装，仅生成空数据结构", file=sys.stderr)
    
    # 获取行业新闻
    industry_news = fetch_industry_news()
    
    # 获取个股新闻
    company_news = {}
    print("\n  📰 获取个股新闻...", file=sys.stderr)
    for company in COMPANIES[:10]:  # 限制前10家避免请求过多
        print(f"    {company}...", end="", file=sys.stderr)
        news = fetch_company_news(company)
        if news:
            company_news[company] = {"name": company, "news": news}
            print(f" ✅ {len(news)}条", file=sys.stderr)
        else:
            print(" ⚠️ 无数据", file=sys.stderr)
        time.sleep(0.3)
    
    # 获取财务数据（采样几家核心公司）
    financials = {}
    core_companies = {
        "002594": "比亚迪",
        "300750": "宁德时代",  # 对比
        "002466": "天齐锂业"
    }
    print("\n  💹 获取财务数据（采样）...", file=sys.stderr)
    for code, name in core_companies.items():
        print(f"    {name}({code})...", end="", file=sys.stderr)
        fin = fetch_financial_data(code)
        if fin:
            financials[code] = {"name": name, "data": fin}
            print(f" ✅", file=sys.stderr)
        else:
            print(" ⚠️ 无数据", file=sys.stderr)
        time.sleep(0.5)
    
    # 组装输出
    output = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "date": datetime.now().strftime("%Y-%m-%d"),
        "industry_news": industry_news,
        "company_news": company_news,
        "financials": financials  # 用于PEG计算
    }
    
    import argparse
    parser = argparse.ArgumentParser(description="比亚迪产业链新闻获取器")
    parser.add_argument("--output", "-o", default="news_data.json", help="输出文件路径")
    args, _ = parser.parse_known_args()

    output_file = args.output
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"\n💾 数据已保存到 {output_file}", file=sys.stderr)
    print(f"  - 行业新闻: {len(industry_news)} 条", file=sys.stderr)
    print(f"  - 个股新闻: {len(company_news)} 家公司", file=sys.stderr)
    print(f"  - 财务数据: {len(financials)} 家公司", file=sys.stderr)

if __name__ == "__main__":
    main()
