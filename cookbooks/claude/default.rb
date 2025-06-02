directory "#{ENV['HOME']}/.claude" do
  mode '0755'
end

dotfile ".claude/settings.json"
dotfile ".claude/CLAUDE.md"
dotfile ".claude/commands"
