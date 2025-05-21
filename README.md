# test-serverless

Serverless Framework を使用して AWS Lambda を構築するためのテンプレートリポジトリです。  
Python ランタイム、複数プラグイン、Docker コンテナを利用し、開発・デプロイを効率化します。

---

## 🛠 プロジェクト作成ログ(リポジトリではこれが完了した状態なので参考程度)

以下の順でプロジェクトを作成します

### 🔧 初期状態とファイル構成

プロジェクト作成前は以下のファイル構成になっています：

- `./infra/`：インフラ定義ファイル群
- `.gitignore`
- `docker-compose.yml`
- `Makefile`
- `README.md`

> ⚠️ `serverless/` ディレクトリは不要です（プロジェクト作成時に生成されます）

---

### 🔧 プロジェクト作成コマンド

以下のコマンドで Serverless プロジェクトを作成します。
途中で手動での操作が必要です（次項で述べています）。

```bash
make sls-create
```

---

### 🧑‍🏫 手動操作手順

プロジェクト作成中に、以下の手動操作が必要です：

1. **テンプレート選択**：
   - `AWS` / `Python` / `HTTP API` を選択
2. **プロジェクト名入力**：
   - `serverless` と入力（`serverless/` ディレクトリが自動生成される）
3. **ブラウザでログイン**：
   - Serverless Framework アカウントでログイン（ver4以上では必須）
4. **アプリ追加はスキップ**：
   - 「Skip Adding An App」を選択（dashboardは使用しないため）
5. **AWS SSO / ENV Vars 設定は後回し**：
   - 「Skip & Set Later」を選択（SSO認証を使用するため）

---

## 🚀 プロジェクト起動（コンテナ）

以下のコマンドで、デプロイ用・テスト用の Docker コンテナを立ち上げます：

```bash
make reset
```

---

## 🔌 プラグインの追加

必要な Serverless プラグインをコンテナ内でインストールします：

```bash
docker compose exec sls-deploy serverless plugin install --name serverless-iam-roles-per-function
docker compose exec sls-deploy serverless plugin install --name serverless-python-requirements
docker compose exec sls-deploy serverless plugin install --name serverless-prune-plugin
docker compose exec sls-deploy serverless plugin install --name serverless-plugin-lambda-insights
docker compose exec sls-deploy serverless plugin install --name serverless-plugin-aws-alerts
docker compose exec sls-deploy serverless plugin install --name serverless-domain-manager
```

---

## ⚙️ `serverless.yml` の設定項目

### ✅ プロバイダー設定

### 🚀 関数定義

### 🧱 リソース定義

---

## 📂 ディレクトリ構成（例）

```bash
test-serverless/.
├── docker-compose.yml
├── Makefile
├── README.md
├── infra
│   └── docker
│       └── development
│           ├── python
│           │   └── Dockerfile
│           ├── sls-create
│           │   └── Dockerfile
│           └── sls-deploy
│               └── Dockerfile
└── serverless
    ├── .gitignore
    ├── handler.py
    ├── README.md
    └── serverless.yml
```

---

## 📚 補足

- Serverless のバージョンは v4 以上を想定(v3までは無料だが、sso利用時にserverless-better-credentialsプラグインが必要)
- Serverless Framework の詳細は [公式ドキュメント](https://www.serverless.com/framework/docs/) を参照
