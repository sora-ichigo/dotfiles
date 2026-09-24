---
name: excalidraw-export
description: .excalidraw ファイルを PNG 画像にエクスポートする。Playwright で Chromium を開き、Excalidraw 公式の @excalidraw/utils の exportToSvg で SVG を描画してから PNG として保存する
argument-hint: <input.excalidraw> [出力先 / オプション]
---

`.excalidraw`（Excalidraw のシーン JSON）を PNG に書き出します。

## 手順

1. 対象ファイルを特定する。引数がなければ、会話の文脈やカレントディレクトリの `*.excalidraw` から判断し、曖昧ならユーザーに確認する
2. 同梱スクリプトを実行する

```bash
~/.claude/skills/excalidraw-export/scripts/export.sh <input.excalidraw> [options]
```

| オプション | 既定値 | 説明 |
| --- | --- | --- |
| `-o, --output <path>` | 入力と同じ場所の `<name>.png` | PNG の出力先 |
| `--scale <n>` | `2` | 解像度の倍率 |
| `--padding <px>` | `10` | 図の周囲の余白 |
| `--dark` | なし | ダークテーマで書き出す |
| `--transparent` | なし | 背景を透過にする |
| `--svg <path>` | なし | 中間の SVG も保存する |

3. 出力された PNG を Read で開いて描画結果（テキスト・フォント・画像の欠け）を確認し、出力パスとサイズを報告する

## 仕組み

- 初回実行時に `~/.cache/claude-excalidraw-export` へ `playwright` と `@excalidraw/utils` をインストールし、Chromium をダウンロードする（数分かかるため Bash の timeout を長めに取る）
- `page.route` でローカルの `@excalidraw/utils` を配信し、ブラウザ内で `exportToSvg` を実行する。フォントはサブセット化されて SVG に埋め込まれる
- SVG を DOM に挿入してフォントの読み込みを待ち、`deviceScaleFactor` に倍率を設定した要素スクリーンショットで PNG にする
- ライブラリのバージョンは `export.sh` 冒頭で固定している。更新するときはそこを書き換える
