#!/usr/bin/env python3
"""
比亚迪产业链 — 全市场股票数据获取（腾讯财经接口版）
稳定可靠，支持 A股/港股/美股批量获取
"""

import json
import sys
import time
import requests
from datetime import datetime

HEADERS = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"}

# ============================================================
# 产业链公司列表
# ============================================================
COMPANIES = [
    # === 核心 ===
    {"name": "比亚迪", "name_en": "BYD", "role": "新能源汽车龙头(A)", "category": "core", "market": "SZ", "code": "002594"},
    {"name": "比亚迪", "name_en": "BYD", "role": "新能源汽车龙头(港)", "category": "core", "market": "HK", "code": "01211", "tencent": "hk01211"},
    
    # === 上游 — 矿产资源 ===
    {"name": "天齐锂业", "name_en": "Tianqi Lithium", "role": "锂盐/碳酸锂(A)", "category": "upstream_mining", "market": "SZ", "code": "002466"},
    {"name": "天齐锂业", "name_en": "Tianqi Lithium", "role": "锂盐/碳酸锂(港)", "category": "upstream_mining", "market": "HK", "code": "09696", "tencent": "hk09696"},
    {"name": "赣锋锂业", "name_en": "Ganfeng Lithium", "role": "锂化合物/金属锂(A)", "category": "upstream_mining", "market": "SZ", "code": "002460"},
    {"name": "赣锋锂业", "name_en": "Ganfeng Lithium", "role": "锂化合物/金属锂(港)", "category": "upstream_mining", "market": "HK", "code": "01772", "tencent": "hk01772"},
    {"name": "华友钴业", "name_en": "Huayou Cobalt", "role": "钴材料/三元前驱体", "category": "upstream_mining", "market": "SH", "code": "603799"},
    {"name": "洛阳钼业", "name_en": "CMOC", "role": "钴镍资源(A)", "category": "upstream_mining", "market": "SH", "code": "603993"},
    {"name": "洛阳钼业", "name_en": "CMOC", "role": "钴镍资源(港)", "category": "upstream_mining", "market": "HK", "code": "03993", "tencent": "hk03993"},
    
    # === 上游 — 核心材料 ===
    {"name": "湖南裕能", "name_en": "Hunan Yuneng", "role": "磷酸铁锂正极", "category": "upstream_material", "market": "SZ", "code": "301358"},
    {"name": "德方纳米", "name_en": "Dynanonic", "role": "磷酸铁锂正极", "category": "upstream_material", "market": "SZ", "code": "300769"},
    {"name": "璞泰来", "name_en": "Putailai", "role": "负极材料/涂覆隔膜", "category": "upstream_material", "market": "SH", "code": "603659"},
    {"name": "贝特瑞", "name_en": "BTR New Material", "role": "负极材料", "category": "upstream_material", "market": "BJ", "code": "835185"},
    {"name": "恩捷股份", "name_en": "Enjie", "role": "锂电隔膜", "category": "upstream_material", "market": "SZ", "code": "002812"},
    {"name": "天赐材料", "name_en": "Tinci Materials", "role": "电解液", "category": "upstream_material", "market": "SZ", "code": "002709"},
    {"name": "新宙邦", "name_en": "Capchem", "role": "电解液", "category": "upstream_material", "market": "SZ", "code": "300037"},
    
    # === 上游 — 锂电设备 ===
    {"name": "先导智能", "name_en": "Lead Intelligent", "role": "锂电池生产设备(A)", "category": "upstream_equipment", "market": "SZ", "code": "300450"},
    {"name": "先导智能", "name_en": "Lead Intelligent", "role": "锂电池生产设备(港)", "category": "upstream_equipment", "market": "HK", "code": "00470", "tencent": "hk00470"},
    {"name": "赢合科技", "name_en": "Yinghe Technology", "role": "锂电池设备", "category": "upstream_equipment", "market": "SZ", "code": "300457"},
    {"name": "北方华创", "name_en": "Naura", "role": "半导体/新能源装备", "category": "upstream_equipment", "market": "SZ", "code": "002371"},
    
    # === 下游 — 新能源整车厂 ===
    {"name": "特斯拉", "name_en": "Tesla", "role": "全球电动车龙头", "category": "downstream_auto", "market": "US", "code": "TSLA", "tencent": "usTSLA"},
    {"name": "理想汽车", "name_en": "Li Auto", "role": "增程式电动车(美)", "category": "downstream_auto", "market": "US", "code": "LI", "tencent": "usLI"},
    {"name": "理想汽车", "name_en": "Li Auto", "role": "增程式电动车(港)", "category": "downstream_auto", "market": "HK", "code": "02015", "tencent": "hk02015"},
    {"name": "蔚来汽车", "name_en": "NIO", "role": "智能电动车(美)", "category": "downstream_auto", "market": "US", "code": "NIO", "tencent": "usNIO"},
    {"name": "蔚来汽车", "name_en": "NIO", "role": "智能电动车(港)", "category": "downstream_auto", "market": "HK", "code": "09866", "tencent": "hk09866"},
    {"name": "小鹏汽车", "name_en": "XPeng", "role": "智能电动车(美)", "category": "downstream_auto", "market": "US", "code": "XPEV", "tencent": "usXPEV"},
    {"name": "小鹏汽车", "name_en": "XPeng", "role": "智能电动车(港)", "category": "downstream_auto", "market": "HK", "code": "09868", "tencent": "hk09868"},
    {"name": "小米集团", "name_en": "Xiaomi", "role": "SU7系列竞品", "category": "downstream_auto", "market": "HK", "code": "01810", "tencent": "hk01810"},
    
    # === 下游 — 电子及储能 ===
    {"name": "比亚迪电子", "name_en": "BYD Electronic", "role": "手机部件及组装", "category": "downstream_electronics", "market": "HK", "code": "00285", "tencent": "hk00285"},
    {"name": "阳光电源", "name_en": "Sungrow", "role": "光伏逆变器+储能", "category": "downstream_energy", "market": "SZ", "code": "300274"},
    {"name": "科华数据", "name_en": "Kehua Data", "role": "储能系统", "category": "downstream_energy", "market": "SZ", "code": "002335"},
]


def get_tencent_code(c):
    """转换为腾讯财经代码格式"""
    if "tencent" in c:
        return c["tencent"]
    m = c["market"]
    code = c["code"]
    if m == "SH":
        return f"sh{code}"
    elif m == "SZ":
        return f"sz{code}"
    elif m == "BJ":
        return f"bj{code}"
    elif m == "HK":
        return f"hk{code}"
    elif m == "US":
        return f"us{code}"
    return code


def parse_tencent_a_hk(raw, company):
    """解析腾讯财经 A 股/港股数据"""
    # 格式: v_szXXXXXX="51~名称~代码~现价~昨收~今开~成交量~..."
    parts = raw.split("~")
    if len(parts) < 50:
        return {"error": f"数据解析失败: fields={len(parts)}"}
    
    try:
        price = float(parts[3]) if parts[3] else 0
        prev_close = float(parts[4]) if parts[4] else 0
        open_price = float(parts[5]) if parts[5] else 0
        volume = float(parts[6]) if parts[6] else 0
        change_amt = float(parts[31]) if parts[31] else 0
        change_pct = float(parts[32]) if parts[32] else 0
        high = float(parts[33]) if parts[33] else 0
        low = float(parts[34]) if parts[34] else 0
        amount = float(parts[37]) if parts[37] else 0  # 万元
        turnover = float(parts[38]) if parts[38] else 0
        pe = float(parts[39]) if parts[39] else 0
        market_cap = float(parts[45]) if len(parts) > 45 and parts[45] else 0  # 亿
        float_cap = float(parts[44]) if len(parts) > 44 and parts[44] else 0  # 亿
        
        return {
            "name": company["name"],
            "name_en": company["name_en"],
            "code": company["code"],
            "market": company["market"],
            "price": price,
            "prev_close": prev_close,
            "open": open_price,
            "high": high,
            "low": low,
            "volume": volume,
            "amount": amount * 10000,  # 万 -> 元
            "change_pct": change_pct,
            "change_amt": change_amt,
            "turn_over": turnover,
            "pe": pe,
            "market_cap": market_cap * 100000000,  # 亿 -> 元
            "float_cap": float_cap * 100000000,
        }
    except (ValueError, IndexError) as e:
        return {"error": f"解析失败: {e}"}


def parse_tencent_us(raw, company):
    """解析腾讯财经美股数据"""
    parts = raw.split("~")
    if len(parts) < 30:
        return {"error": f"美股数据解析失败: fields={len(parts)}"}
    
    try:
        price = float(parts[3]) if parts[3] else 0
        prev_close = float(parts[4]) if parts[4] else 0
        volume = float(parts[6]) if parts[6] else 0
        change_amt = float(parts[31]) if len(parts) > 31 and parts[31] else 0
        change_pct = float(parts[32]) if len(parts) > 32 and parts[32] else 0
        high = float(parts[33]) if len(parts) > 33 and parts[33] else 0
        low = float(parts[34]) if len(parts) > 34 and parts[34] else 0
        amount = float(parts[37]) if len(parts) > 37 and parts[37] else 0
        pe = float(parts[39]) if len(parts) > 39 and parts[39] else 0
        market_cap = float(parts[45]) if len(parts) > 45 and parts[45] else 0  # 亿
        float_cap = float(parts[44]) if len(parts) > 44 and parts[44] else 0  # 亿
        
        # 如果昨收为0但有涨跌额，用现价反推
        if prev_close == 0 and change_amt != 0:
            prev_close = price - change_amt
        
        return {
            "name": company["name"],
            "name_en": company["name_en"],
            "code": company["code"],
            "market": "US",
            "price": price,
            "prev_close": round(prev_close, 2),
            "open": float(parts[5]) if len(parts) > 5 and parts[5] else 0,
            "high": high,
            "low": low,
            "volume": volume,
            "amount": amount,
            "change_pct": change_pct,
            "change_amt": change_amt,
            "turn_over": float(parts[38]) if len(parts) > 38 and parts[38] else 0,
            "pe": pe,
            "market_cap": market_cap * 100000000,  # 亿 -> 元
            "float_cap": float_cap * 100000000,
        }
    except (ValueError, IndexError) as e:
        return {"error": f"美股解析失败: {e}"}


def fetch_batch(companies, batch_size=20):
    """批量获取数据"""
    results = {}
    
    # 分批请求（腾讯接口支持批量）
    for i in range(0, len(companies), batch_size):
        batch = companies[i:i+batch_size]
        codes = ",".join(get_tencent_code(c) for c in batch)
        url = f"https://qt.gtimg.cn/q={codes}"
        
        print(f"  批次 {i//batch_size+1}: 获取 {len(batch)} 家...", end="", file=sys.stderr, flush=True)
        
        try:
            resp = requests.get(url, headers=HEADERS, timeout=15)
            if resp.status_code != 200:
                print(f" ❌ HTTP {resp.status_code}", file=sys.stderr)
                for c in batch:
                    results[c["code"]] = {"error": f"HTTP {resp.status_code}"}
                continue
            
            # 解析每条数据
            lines = resp.text.strip().split("\n")
            line_map = {}
            for line in lines:
                if "=" in line:
                    var_name, value = line.split("=", 1)
                    # var_name like v_sz300750
                    key = var_name.split("_", 1)[-1] if "_" in var_name else var_name
                    line_map[key] = value.strip('"').strip(";").strip('"')
            
            ok_count = 0
            for c in batch:
                tc = get_tencent_code(c)
                raw = line_map.get(tc, "")
                if not raw or raw == "":
                    results[c["code"]] = {"error": f"{c['name']} 无数据"}
                    continue
                
                if c["market"] == "US":
                    parsed = parse_tencent_us(raw, c)
                else:
                    parsed = parse_tencent_a_hk(raw, c)
                
                results[c["code"]] = parsed
                if "error" not in parsed:
                    ok_count += 1
            
            print(f" ✅ {ok_count}/{len(batch)}", file=sys.stderr)
            
        except Exception as e:
            print(f" ❌ {e}", file=sys.stderr)
            for c in batch:
                results[c["code"]] = {"error": str(e)}
        
        time.sleep(0.5)
    
    return results


def main():
    print("🚗 比亚迪产业链 — 行情数据获取", file=sys.stderr)
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", file=sys.stderr)
    print(f"📊 共 {len(COMPANIES)} 家公司（数据源：腾讯财经）", file=sys.stderr)
    print("", file=sys.stderr)
    
    quotes = fetch_batch(COMPANIES)
    
    # 统计
    success = len([k for k, v in quotes.items() if isinstance(v, dict) and "error" not in v])
    errors = len([k for k, v in quotes.items() if isinstance(v, dict) and "error" in v])
    
    print(f"\n📈 成功: {success} 家  ❌ 失败: {errors} 家", file=sys.stderr)
    
    # 打印摘要
    print("\n" + "=" * 70, file=sys.stderr)
    for c in COMPANIES:
        q = quotes.get(c["code"], {})
        if "error" in q:
            print(f"  ❌ {c['name']:8s} {c['code']:8s} {q['error']}", file=sys.stderr)
        else:
            sign = "+" if q["change_pct"] >= 0 else ""
            currency = "$" if c["market"] == "US" else "HK$" if c["market"] == "HK" else "¥"
            print(f"  ✅ {c['name']:8s} {c['market']}.{c['code']:8s} {currency}{q['price']:>8.2f}  {sign}{q['change_pct']:>6.2f}%  昨收{currency}{q['prev_close']:.2f}", file=sys.stderr)
    
    output = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "date": datetime.now().strftime("%Y-%m-%d"),
        "source": "Tencent Finance (qt.gtimg.cn)",
        "total_companies": len(COMPANIES),
        "companies": COMPANIES,
        "quotes": quotes,
    }
    
    import argparse
    parser = argparse.ArgumentParser(description="比亚迪产业链股价获取器")
    parser.add_argument("--output", "-o", default="stock_data.json", help="输出文件路径")
    args, _ = parser.parse_known_args()

    output_file = args.output
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"\n💾 数据已保存到 {output_file}", file=sys.stderr)


if __name__ == "__main__":
    main()
