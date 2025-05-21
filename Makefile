### development
stage?=stg
region?=ap-northeast-1
aws_profile?=default

.PHONY: deploy
deploy:
	docker compose exec sls-deploy serverless deploy --stage $(stage) --region $(region) --aws-profile $(aws_profile)

.PHONY: deploy-debug
deploy-debug:
	docker compose exec sls-deploy serverless deploy --stage $(stage) --region $(region) --aws-profile $(aws_profile) --debug

.PHONY: up
up:
	docker compose up -d

.PHONY: down
down:
	docker compose down

.PHONY: stop
stop:
	docker compose stop

# git clone直後の状態からアプリケーション起動まで(env修正のみ手動)
.PHONY: init
init:
	docker compose build --no-cache
	make up

# git clone直後の状態に戻す
.PHONY: destroy
destroy:
	docker compose down --rmi all --volumes --remove-orphans
	rm -rf serverless/node_modules

.PHONY: reset
reset:
	make destroy
	make init

# pullしてきたとき
# make init

### sls-create-create(serverlessプロジェクト作成)
.PHONY: sls-create-create
sls-create:
	rm -rf serverless
	docker build -t sls-create-image ./infra/docker/development/sls-create --no-cache
	docker run -d --name sls-create-container -it --mount type=bind,source=$(shell pwd),target=/sls-create sls-create-image
	docker exec -it sls-create-container serverless
	docker stop sls-create-container
	docker rm sls-create-container
	docker rmi sls-create-image
	rm -rf .serverless

# serverlessプロジェクト作成備忘録
# infra/, docker-compose.yml, Makefile, README.mdでスタート
# make sls-create
# serverlessするときに手動確認ある
# templateはAWS / Python / HTTP API
# プロジェクト名はserverlessを指定(serverlessディレクトリができる)
# ブラウザでserverlessにログイン(ver4以上では必須)
# Skip Adding An Appを選択(dashboardは使わないので)
# Skip & Set Later (AWS SSO, ENV Vars)を選択(SSOで認証するので)
# make reset
# docker compose exec sls-deploy serverless plugin install --name serverless-iam-roles-per-function
# docker compose exec sls-deploy serverless plugin install --name serverless-python-requirements
# docker compose exec sls-deploy serverless plugin install --name serverless-prune-plugin
# docker compose exec sls-deploy serverless plugin install --name serverless-plugin lambda-insights
# docker compose exec sls-deploy serverless plugin install --name serverless-plugin-aws-alerts
# docker compose exec sls-deploy serverless plugin install --name serverless-domain-manager #apigatewayのカスタムドメイン？
# 必要なら以下も(このプロジェクトでは使わないかも)
# docker compose exec sls-deploy serverless plugin install --name serverless-plugin-warmup #コールドスタート防止用
# docker compose exec sls-deploy serverless plugin install --name serverless-plugin-finch #S3に静的コンテンツをデプロイする？workflowで自分でやった方がいい気もする
