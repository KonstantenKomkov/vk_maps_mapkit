#!/usr/bin/env python3
"""Снимает страницы документации VK Карт (dev.vk.ru) в Markdown.

Использование:
    python3 tool/fetch_docs.py documents/research/dev_vk_ru urls.txt
    python3 tool/fetch_docs.py documents/research/dev_vk_ru https://dev.vk.ru/ru/vkmaps/...

Контент страниц отрендерен на сервере внутри <div data-t="page-content">, поэтому
хватает обычного GET без браузера. Файл кладётся по пути из URL: путь после
/ru/vkmaps/ превращается в вложенные каталоги, последний сегмент — имя .md.
"""
import os
import re
import sys
import time
import urllib.request

from bs4 import BeautifulSoup, NavigableString

# dev.vk.ru отдаёт серверный рендер (~27 КБ с блоком page-content) только не-браузерным
# User-Agent; с UA Chrome возвращается пустая SPA-оболочка на 4,7 КБ без контента.
UA = "curl/8.7.1"


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=40) as r:
        return r.read().decode("utf-8", "replace")


def inline(node) -> str:
    """Инлайновый текст с сохранением code/strong/em/ссылок."""
    out = []
    for ch in node.children:
        if isinstance(ch, NavigableString):
            out.append(str(ch))
        elif ch.name in ("script", "style", "svg", "button"):
            continue
        elif ch.name == "code":
            out.append("`" + ch.get_text().strip() + "`")
        elif ch.name in ("strong", "b"):
            out.append("**" + inline(ch).strip() + "**")
        elif ch.name in ("em", "i"):
            out.append("*" + inline(ch).strip() + "*")
        elif ch.name == "img":
            src = ch.get("src", "")
            if src:
                out.append(f"![{ch.get('alt', '')}]({src})")
        elif ch.name == "a":
            text = inline(ch).strip()
            href = ch.get("href", "")
            if not text:
                continue
            out.append(f"[{text}]({href})" if href.startswith("http") else text)
        elif ch.name == "br":
            out.append("\n")
        else:
            out.append(inline(ch))
    return re.sub(r"[ \t]+", " ", "".join(out)).replace(" ", " ")


def code_block(node) -> str:
    lang = ""
    for cls in node.get("class", []):
        if cls.startswith("language-"):
            lang = cls[len("language-"):]
    text = node.get_text().rstrip()
    if not lang and text.lstrip()[:1] in "{[":
        lang = "json"  # примеры ответов размечены <code> без класса языка
    return f"```{lang}\n{text}\n```"


def table(node) -> str:
    rows = []
    for tr in node.find_all("tr"):
        cells = [inline(td).strip().replace("|", "\\|") for td in tr.find_all(["th", "td"])]
        if cells:
            rows.append(cells)
    if not rows:
        return ""
    width = max(len(r) for r in rows)
    rows = [r + [""] * (width - len(r)) for r in rows]
    head, body = rows[0], rows[1:]
    lines = ["| " + " | ".join(head) + " |", "| " + " | ".join(["---"] * width) + " |"]
    lines += ["| " + " | ".join(r) + " |" for r in body]
    return "\n".join(lines)


def walk(node, out, depth=0):
    for ch in node.children:
        if isinstance(ch, NavigableString) or ch.name in ("script", "style", "svg", "button"):
            continue
        if ch.name in ("h1", "h2", "h3", "h4", "h5"):
            out.append("#" * int(ch.name[1]) + " " + inline(ch).strip())
        elif ch.name == "p":
            text = inline(ch).strip()
            if text:
                out.append(text)
        elif ch.name == "code":
            if any(c.startswith("language-") for c in ch.get("class", [])) or "\n" in ch.get_text():
                out.append(code_block(ch))
            else:
                out.append("`" + ch.get_text().strip() + "`")
        elif ch.name in ("ul", "ol"):
            marker = "-" if ch.name == "ul" else "1."
            items = []
            for li in ch.find_all("li", recursive=False):
                # в вёрстке маркер списка — отдельный span с «•», в Markdown он лишний
                text = re.sub(r"^[•\-–—]\s*", "", inline(li).strip())
                text = re.sub(r"\s*\n\s*", " ", text).strip()
                if text:
                    items.append(f"{marker} " + text)
            if items:
                out.append("\n".join(items))
        elif ch.name == "table":
            out.append(table(ch))
        elif ch.name == "blockquote":
            out.append("> " + inline(ch).strip())
        else:
            walk(ch, out, depth + 1)


def to_markdown(html: str, url: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    content = soup.find("div", attrs={"data-t": "page-content"}) or soup.find("main")
    if content is None:
        raise RuntimeError("не найден блок контента")
    out = []
    walk(content, out)
    body = "\n\n".join(x for x in out if x.strip())
    body = re.sub(r"\n{3,}", "\n\n", body)
    return f"<!-- Источник: {url} -->\n<!-- Снято: {time.strftime('%Y-%m-%d')} -->\n\n{body}\n"


def target_path(root: str, url: str) -> str:
    tail = url.split("/ru/vkmaps/", 1)[1] if "/ru/vkmaps/" in url else url.rsplit("/", 1)[-1]
    return os.path.join(root, tail.strip("/") + ".md")


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    root, args = sys.argv[1], sys.argv[2:]
    urls = []
    for a in args:
        if a.startswith("http"):
            urls.append(a)
        else:
            urls += [ln.strip() for ln in open(a, encoding="utf-8") if ln.strip().startswith("http")]
    fails = 0
    for url in urls:
        path = target_path(root, url)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        try:
            md = to_markdown(fetch(url), url)
        except Exception as e:  # noqa: BLE001 — нужен отчёт по всем страницам, а не падение на первой
            print(f"ОШИБКА {url}: {e}")
            fails += 1
            continue
        with open(path, "w", encoding="utf-8") as f:
            f.write(md)
        print(f"{len(md):7d} Б  {path}")
        time.sleep(0.4)
    print(f"\nготово: {len(urls) - fails} из {len(urls)}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
