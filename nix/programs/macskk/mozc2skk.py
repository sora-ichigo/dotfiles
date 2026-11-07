import re
import sys
from collections import defaultdict

ROMAJI = {}
for kana, cons in [
    ("あいうえおぁぃぅぇぉ", None),
    ("かきくけこ", "k"), ("がぎぐげご", "g"),
    ("さしすせそ", "s"), ("ざじずぜぞ", "z"),
    ("たちつてとっ", "t"), ("だぢづでど", "d"),
    ("なにぬねのん", "n"),
    ("はひふへほ", "h"), ("ばびぶべぼ", "b"), ("ぱぴぷぺぽ", "p"),
    ("まみむめも", "m"),
    ("やゆよゃゅょ", "y"),
    ("らりるれろ", "r"),
    ("わを", "w"),
]:
    for c in kana:
        ROMAJI[c] = cons

for c, v in zip("あいうえおぁぃぅぇぉ", "aiueoaiueo"):
    ROMAJI[c] = v

READING = re.compile(r"^[ぁ-んー]+$")
KANJI = re.compile(r"[一-龯々〆ヵヶ]")
TAIL = re.compile(r"[ぁ-ん]+$")


def katakana(s):
    return "".join(chr(ord(c) + 0x60) if "ぁ" <= c <= "ゖ" else c for c in s)


def okuri_entry(reading, surface):
    m = TAIL.search(surface)
    if not m:
        return None
    tail = m.group(0)
    stem = surface[: m.start()]
    if not stem or not KANJI.search(stem[-1]) or not reading.endswith(tail) or len(reading) <= len(tail):
        return None
    cons = ROMAJI.get(tail[0])
    if cons is None:
        return None
    return reading[: -len(tail)] + cons, stem


def main(out, paths):
    nasi = defaultdict(dict)
    ari = defaultdict(dict)
    for path in paths:
        with open(path, encoding="utf-8") as f:
            for line in f:
                cols = line.rstrip("\n").split("\t")
                if len(cols) < 5:
                    continue
                reading, cost, surface = cols[0], int(cols[3]), cols[4]
                if not READING.match(reading) or surface in (reading, katakana(reading)) or "/" in surface or ";" in surface:
                    continue
                try:
                    surface.encode("euc_jp")
                except UnicodeEncodeError:
                    continue
                if cost < nasi[reading].get(surface, 1 << 30):
                    nasi[reading][surface] = cost
                o = okuri_entry(reading, surface)
                if o and cost < ari[o[0]].get(o[1], 1 << 30):
                    ari[o[0]][o[1]] = cost

    def emit(table, keys):
        for k in keys:
            cands = sorted(table[k], key=table[k].get)
            out.write(k + " /" + "/".join(cands) + "/\n")

    out.write(";; -*- coding: euc-jp -*-\n;; okuri-ari entries.\n")
    emit(ari, sorted(ari, reverse=True))
    out.write(";; okuri-nasi entries.\n")
    emit(nasi, sorted(nasi))


with open(sys.argv[1], "w", encoding="euc_jp") as out:
    main(out, sys.argv[2:])
