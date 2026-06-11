# Claude Code dotfiles setup script
# Run this on a new PC to set up ~/.claude/

$claudeDir = "$env:USERPROFILE\.claude"

# Create directory structure
New-Item -ItemType Directory -Force "$claudeDir\templates\.github\workflows" | Out-Null

# Copy files
Copy-Item "$PSScriptRoot\CLAUDE.md" "$claudeDir\CLAUDE.md" -Force
Copy-Item "$PSScriptRoot\templates\.github\workflows\linear-sync.yml" "$claudeDir\templates\.github\workflows\linear-sync.yml" -Force

Write-Host "Setup complete. Files copied to $claudeDir"
Write-Host ""
Write-Host "Remaining manual step:"
Write-Host "  Place your Linear API key at: $claudeDir\linear-api-key.txt"
