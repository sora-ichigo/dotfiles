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
- ツール自身が設定ファイルに書き戻す場合は `home.file` を使わない。Nix store へのシンボリックリンクは読み取り専用のため書き込みが失敗する。`home.activation` で書き込み可能な実ファイルとしてコピーし、ツールが書き込む区画だけ引き継ぐ
  - `nix/programs/codex.nix` がこの形。codex は trust したディレクトリを `[projects."<絶対パス>"]` として `config.toml` に書き込むため、コピー時に既存の `[projects]` ブロックを引き継いでいる（trust は完全一致のみで、親ディレクトリからの継承や再帰指定はできない）

### AI コーディングエージェントの設定

- Claude Code / codex はそれぞれ `config/.claude/`、`config/.codex/` に設定を置く
- メモリファイル（`CLAUDE.md` / `AGENTS.md`）はツールごとに実体を分ける。共通の方針は同じ内容を書き、ツール固有の記述だけ差し替える
- skills は `config/.claude/skills/` を単一のソースとする。SKILL.md の frontmatter には `name` を書く（Claude Code はディレクトリ名から推論するので省略できるが、Agent Skills 標準に準拠した他ツールは `name` を要求する）
- MCP サーバーの定義はツールごとにフォーマットが異なるため個別に持つ
  - Claude Code: `config/.claude/mcp.json` を `make claude-code` が `claude mcp add` に流し込む
  - codex: `config/.codex/config.toml` の `[mcp_servers.*]`

### 導入を見送ったツール

- Gemini CLI: 2026-06-18 に個人向け OAuth サインイン（無料枠 / AI Pro / Ultra）が停止され、個人アカウントでは利用できないため導入しない。使うには billing 有効な API キー、Vertex AI、または Code Assist Standard/Enterprise ライセンスが必要

## Memories

- dotfile管理を足すときは Home Manager の設定を使う
