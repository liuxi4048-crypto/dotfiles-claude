# load-repo.ps1
# 「作業開始」hook: claude-workspaceリポジトリの内容をClaudeに渡す

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoUrl = "https://github.com/liuxi4048-crypto/claude-workspace"
$repoPath = "$env:USERPROFILE\.claude\workspace\claude-workspace"

# リポジトリをclone or pull
if (Test-Path "$repoPath\.git") {
    git -C $repoPath pull --quiet 2>$null
} else {
    New-Item -ItemType Directory -Force (Split-Path $repoPath) | Out-Null
    git clone --quiet $repoUrl $repoPath 2>$null
}

$output = @()
$output += "===== 作業開始: リポジトリ情報の自動読み込み ====="
$output += ""
$output += "## リポジトリ"
$output += $repoUrl
$output += ""

# 現在のブランチ
$branch = git -C $repoPath branch --show-current 2>$null
$output += "## 現在のブランチ"
$output += $branch
$output += ""

# 直近のコミット
$output += "## 直近のコミット (5件)"
$log = git -C $repoPath log --oneline -5 2>$null
$output += $log
$output += ""

# ファイルツリー
$output += "## ファイルツリー"
$tree = git -C $repoPath ls-files | Where-Object {
    $_ -notmatch "^node_modules/" -and
    $_ -notmatch "^\.git/" -and
    $_ -notmatch "^dist/" -and
    $_ -notmatch "^build/" -and
    $_ -notmatch "package-lock\.json$" -and
    $_ -notmatch "\.png$" -and $_ -notmatch "\.jpg$" -and $_ -notmatch "\.ico$"
}
$output += $tree
$output += ""

# 主要ファイルの内容
$keyFiles = @("README.md", "package.json", "CLAUDE.md", "tsconfig.json", ".env.example")
foreach ($file in $keyFiles) {
    $fullPath = Join-Path $repoPath $file
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Length -lt 3000) {
            $output += "## $file"
            $output += $content
            $output += ""
        }
    }
}

$output += "===== 以上がリポジトリの現状です。作業を開始してください。 ====="

Write-Output ($output -join "`n")
