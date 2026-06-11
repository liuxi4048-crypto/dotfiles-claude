# load-repo.ps1
# 「作業開始」hook: カレントディレクトリのリポジトリ情報をClaudeに渡す

$repoPath = (Get-Location).Path

# gitリポジトリでなければスキップ
$isGit = git -C $repoPath rev-parse --is-inside-work-tree 2>$null
if (-not $isGit) {
    Write-Output "【注意】カレントディレクトリはGitリポジトリではありません: $repoPath"
    exit 0
}

$output = @()
$output += "===== 作業開始: リポジトリ情報の自動読み込み ====="
$output += ""

# リモートURL
$remoteUrl = git -C $repoPath remote get-url origin 2>$null
if ($remoteUrl) {
    $output += "## リポジトリ"
    $output += $remoteUrl
    $output += ""
}

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

# ファイルツリー（深さ3まで、node_modules等除外）
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

# 主要ファイルの内容を読み込む
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
