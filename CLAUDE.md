# Claude Code プロジェクトルール

## GitHub連携
- ファイルを編集・作成するたびに自動でgit commit & pushを行う
- コミットメッセージは変更内容を日本語で簡潔に記述すること
- mainブランチに直接pushしてよい

## 新規プロジェクト開始時の手順（自動実行）

**ユーザーが開発作業を依頼したとき、現在のディレクトリがGitリポジトリでない場合は、ユーザーへの確認なしに以下の手順を自動で実行すること。リポジトリ名が不明な場合のみプロジェクト名を一度だけ確認する。**

1. Gitの初期化
2. GitHubにリポジトリを新規作成（GitHub MCP経由）
3. リモートを設定して初期push
4. `.github/workflows/linear-sync.yml` を作成（`$env:USERPROFILE\.claude\templates\.github\workflows\linear-sync.yml` の内容をコピー）してcommit & push
5. Linear APIキーをGitHubシークレットに登録：`Get-Content $env:USERPROFILE\.claude\linear-api-key.txt | gh secret set LINEAR_API_KEY --repo <owner>/<repo>`
6. 手順完了後、セットアップが完了した旨をユーザーに報告してから開発作業を続行する

## Linear連携
- PR作成・更新時にLinearと自動同期する（linear-sync.yml）
- PRタイトルまたはブランチ名にLinearのイシューID（例: ENG-123）が含まれる場合 → そのイシューにPRをリンクし、マージ時にDoneへ更新
- イシューIDがない場合 → Linearに新規イシューを自動作成してPRにコメントでリンクを通知
- GitHubリポジトリのSecrets（Settings → Secrets → Actions）に `LINEAR_API_KEY` を必ず設定すること

## 自動commit & pushのルール
- Write / Edit / MultiEdit ツール使用後に自動でcommit & pushが走る
- Gitリポジトリでない場合はスキップされる（エラーにならない）
- pushに失敗してもClaudeの作業は止めない

## Bashコマンドの安全なパス記法（全セッション共通）
- Windowsパスを Bash コマンドに渡すとき、末尾にバックスラッシュを付けない
  - ❌ `ls C:\Claude\` → ✅ `ls 'C:\Claude'`
  - 理由: `\ ` (バックスラッシュ＋スペース) がセキュリティ警告を誘発し、allow リストを無効化する
- ディレクトリ一覧は `Get-ChildItem 'C:\Claude'` または `ls 'C:\Claude'` を使う
- git コマンドは `cd && git` でなく `git -C 'C:\Claude\...'` 形式を使う

## カスタムスキル

### /pdf-project-scaffold
PDFや仕様書を読み込んで（画像含む）、Eclipse・VS Codeのプロジェクトにファイル・フォルダを自動生成するスキル。
- `$env:USERPROFILE\.claude\skills\pdf-project-scaffold\SKILL.md` に定義
- PDFをページ画像に変換してからビジョンで解析する
- 出力結果スクリーンショットを読み取り、それに合わせてファイルを生成する
- Eclipse（.projectファイル）とVS Code（.vscodeフォルダ）を自動検出

使用例：「このPDFに従ってEclipseプロジェクトにQ9から実装して」

## PDF読み込みルール（全スキル共通）
- PDFを読み込む際は必ず画像として各ページを読み込むこと（テキスト抽出のみ禁止）
- 出力結果（動作結果スクリーンショット）がある場合は必ずそれを参照してファイルを生成する
- pymupdfを使ってPDFをPNG画像に変換してからReadツールで読み込む
