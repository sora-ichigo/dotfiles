# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a dotfiles repository using Nix with Home Manager for declarative package and configuration management on macOS. Homebrew (via Brewfile) is used for GUI applications that are not available in Nix.

## Common Commands

```bash
# Apply Nix/Home Manager configuration
make nix

# Install Homebrew packages
make brew
```

## Architecture

### Core Structure

- `nix/flake.nix`: Nix flake definition
- `nix/home.nix`: Main Home Manager configuration (imports program modules and defines packages)
- `nix/programs/`: Per-program Nix configurations
- `config/`: Application configuration files (symlinked to `$HOME`)
- `Brewfile`: Homebrew packages (primarily GUI applications)
- `install.sh`: Script to install Nix and apply Home Manager configuration

### Adding New Packages

#### Nix Packages (CLI tools)

Add to `home.packages` in `nix/home.nix`:

```nix
home.packages = with pkgs; [
  # existing packages...
  new-package-name
];
```

#### Program with Configuration

Create a new file in `nix/programs/`:

```nix
# nix/programs/tool-name.nix
{ config, pkgs, ... }:

{
  programs.toolName = {
    enable = true;
    # additional configuration
  };
}
```

Then import it in `nix/home.nix`:

```nix
imports = [
  # existing imports...
  ./programs/tool-name.nix
];
```

#### Homebrew Cask (GUI apps)

Add to `Brewfile`:

```ruby
cask "app-name"
```

### Configuration Files Management

- Place application config files in `config/` directory matching the target location structure
- Files in `config/` are symlinked to `$HOME/` by Home Manager or manually
- For Nix-managed programs, prefer using Home Manager's native configuration options
- ghq の root 外に実体を置く必要があるリポジトリ（Obsidian vault 内のものなど）は、`nix/programs/ghq.nix` で `mkOutOfStoreSymlink` を使い、ghq 側のパスから実体へのシンボリックリンクを張る
- ツール自身が設定ファイルに書き戻す場合は `home.file` を使わない。Nix store へのシンボリックリンクは読み取り専用のため書き込みが失敗する。`home.activation` で書き込み可能な実ファイルとしてコピーし、ツールが書き込む区画だけ引き継ぐ
- 起動中に設定を読み込むツールは `home.activation` で明示的に再起動・再読込する。Home Manager はシンボリックリンクを張り替えるだけで、稼働中のプロセスには何も伝えない。launchd agent も plist が前回と同一なら Home Manager 側の処理ごとスキップされるため、設定だけを変えても反映されない。SketchyBar は `launchctl kickstart -k` で再起動し、AeroSpace は `aerospace reload-config` で読み直す

### AI コーディングエージェントの設定

- Claude Code の設定は `config/.claude/` に置く
- skills は `config/.claude/skills/` を単一のソースとする。SKILL.md の frontmatter には `name` を書く（Claude Code はディレクトリ名から推論するので省略できるが、Agent Skills 標準に準拠した他ツールは `name` を要求する）
- MCP サーバーは `config/.claude/mcp.json` に定義し、`make claude-code` が `claude mcp add` に流し込む
- 応答完了（Stop）と入力待ち（Notification）の hook で `config/.claude/notify.sh` が terminal-notifier で macOS 通知を出す。応答完了の本文には最後の応答（`last_assistant_message`）の先頭 100 文字を使う。tmux 内で動いていれば、サブタイトルに tmux セッション名を出し、通知をクリックすると WezTerm が前面に出て通知元の pane に切り替わる。`claude agents` のバックグラウンドセッションは daemon 配下で動き `TMUX_PANE` を持たないため、`cwd` かその親ディレクトリで開いている pane（claude が動いている pane を優先）を遷移先にする。環境変数 `CLAUDE_NTFY_TOPIC` があれば ntfy.sh にも送る。有効にするには 1Password にトピック名を保存して `config/secrets.json` に参照を足し、`make secrets` を実行する。トピック名を知っていれば誰でも購読できるため、推測されにくい文字列にする
- SketchyBar（`config/.config/sketchybar/`）を画面左端の縦向きバーとして置く。macOS 標準のメニューバーはコントロールセンター・通知センター・アプリのメニューを使うため残す。中央に `claude agents` のバックグラウンドセッションを出し、クリックで一覧を開く。行をクリックすると、notify.sh と同じ `config/.claude/tmux_pane.sh` でセッションの cwd に近い tmux pane を探して切り替え、見つからなければ WezTerm で attach する。一覧は飛び先の tmux pane ごとにまとめ、pane の見出しに番号を振る。AeroSpace の `alt-c` で一覧を開いて claude モードに入り、見出しの番号キーでその pane に移動できる（`esc` で閉じる）。Claude Code の hook から `sketchybar --trigger claude_agents_update` を呼んで即座に更新する

### 導入していないツール

- codex: 使っていないため設定を削除した
- Gemini CLI: 2026-06-18 に個人向け OAuth サインイン（無料枠 / AI Pro / Ultra）が停止され、個人アカウントでは利用できないため導入しない。使うには billing 有効な API キー、Vertex AI、または Code Assist Standard/Enterprise ライセンスが必要

## Memories

- dotfile管理を足すときは Home Manager の設定を使う
