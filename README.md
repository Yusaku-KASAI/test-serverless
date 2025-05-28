# test-serverless

Serverless Framework を使用して AWS Lambda を構築するためのテンプレートリポジトリです。
Python ランタイム、複数プラグイン、Docker コンテナを利用し、開発・デプロイを効率化します。

---

## 🛠 プロジェクト作成ログ

> ※このリポジトリはプロジェクト作成後の状態です。以下は参考情報としてご利用ください。

### 📁 初期状態とファイル構成

プロジェクト作成前は以下のファイル構成になっています：

* `./infra/`：インフラ定義ファイル群
* `.gitignore`
* `docker-compose.yml`
* `Makefile`
* `README.md`

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

## ⚙️ serverless.yml の設定項目

### ✅ プロバイダー設定

* `stage` & `region` 指定
* ランタイムは Python 3.12
* その他関数の基本共通設定も可能

### 🚀 関数定義（抜粋）

* Lambda 関数を複数定義
* メモリ/タイムアウトの個別指定
* `environment` で環境変数を注入
* `layers` の活用
* 各種トリガー（HTTP, Schedule, S3, DynamoDB, SNS）に対応
* VPC対応Lambdaと非VPC Lambdaを混在

### 🔐 IAM定義（serverless-iam-roles-per-function）

* 関数ごとに権限分離
* `iamRoleStatements` による最小権限ポリシー設定

### 🧱 リソース定義（CloudFormation）

* DynamoDB, S3, SNS, RDS, SecretsManager
* CloudWatch Logs/Alarms、Lambda Insights
* VPC, NAT Gateway, Internet Gateway, Subnet, RouteTable などの基本ネットワーク構成
* VPC Endpoint (S3 / DynamoDB / SecretsManager)

### 📦 環境変数と外部ファイル

* `.env.stg.yml` や `.env.prd.yml` にパラメータを外出し
* `param:` を用いた柔軟な参照を実現

### 🔌 プラグイン設定

* `serverless-iam-roles-per-function`: IAM 分離を有効化
* `serverless-python-requirements`: Python の依存関係解決とレイヤー化
* `serverless-prune-plugin`: 古いデプロイの自動削除
* `serverless-plugin-lambda-insights`: Lambda Insights をデフォルトで有効化
* `serverless-domain-manager`: カスタムドメインに対応

---

## 🚀 プロジェクトデプロイ（コンテナから）

以下のコマンドで、SSO プロファイルを使用してデプロイできます：

```bash
aws sso login --profile profile-name
make deploy aws_profile=profile-name
```

初回デプロイ時はドメイン作成のため以下のコマンドをデプロイ前に打ちます：

> ⚠️ 必要に応じて.env.stg.ymlなどのenvファイルを事前に作成してください

```bash
aws sso login --profile profile-name
make create_domain aws_profile=profile-name
```

---

## 📂 ディレクトリ構成（例）

```bash
test-serverless/
├── docker-compose.yml
├── Makefile
├── README.md
├── infra/
│   └── docker/
│       └── development/
│           ├── python/
│           │   └── Dockerfile
│           ├── sls-create/
│           │   └── Dockerfile
│           └── sls-deploy/
│               └── Dockerfile
└── serverless/
    ├── .gitignore
    ├── handler.py
    ├── README.md
    ├── requirements.txt
    ├── .env.stg.yml
    ├── serverless.yml
    └── handlers/
        ├── apigateway.py
        ├── dynamodb.py
        ├── handler.py
        ├── invoke.py
        ├── lambdainsightsCpu.py
        ├── lambdainsightsMemory.py
        ├── log.py
        ├── rds.py
        ├── s3.py
        └── sns.py
```

---

## 📚 補足

* Serverless のバージョンは v4 以上（v3 以前では一部機能非対応）
* Serverless.yml の構造や `!Ref`, `!GetAtt` の CloudFormation 構文は公式ドキュメント参照
* `.env.stg.yml` による Secrets 情報も適切にハンドリング済
* 今回は事前に認証されたACMおよびホストゾーンのみコンソールでセットアップしている
* 本来はserverlessで管理すべきは、Lambda, APIgateway, dynamoDB, Cloudwatch, SNS(serverlessの運用監視用), IAM(serverless関連), のみにすべきである
* 今回の例では、LambdaInsightsの遅延の影響もあり、アラーム状態が解除されない場合もある（アラームアクションが発火しない）ので適宜調整するようにしたい
* LambdaInsightsをクビにしてログメトリクスフィルタでアラームを飛ばすのもあり(cpuの値などはとれないけど、、メモリとかはいけるので適宜良さそうな構成にする)

---

## 🔗 参考

* [Serverless Framework 公式ドキュメント](https://www.serverless.com/framework/docs/)
* [AWS CloudFormation リファレンス](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-format-reference.html)
