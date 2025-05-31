### development
stage?=stg
region?=ap-northeast-1
aws_profile?=default

.PHONY: deploy
deploy:
	docker compose exec sls-deploy serverless deploy --stage $(stage) --region $(region) --aws-profile $(aws_profile) --param="WAF_WEB_ACL_ARN=$(WAF_WEB_ACL_ARN)" --param="LAMBDA_EDGE_VERSION_ARN=$(LAMBDA_EDGE_VERSION_ARN)"

.PHONY: deploy-debug
deploy-debug:
	docker compose exec sls-deploy serverless deploy --stage $(stage) --region $(region) --aws-profile $(aws_profile) --debug --param="WAF_WEB_ACL_ARN=$(WAF_WEB_ACL_ARN)" --param="LAMBDA_EDGE_VERSION_ARN=$(LAMBDA_EDGE_VERSION_ARN)"

.PHONY: deploy-global
deploy-global:
	docker compose exec sls-deploy serverless deploy --config serverless-global.yml --stage $(stage) --region us-east-1 --aws-profile $(aws_profile)

.PHONY: deploy-all
deploy-all:
	make deploy-global aws_profile=$(aws_profile) stage=$(stage)
	WAF_WEB_ACL_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='WafWebAclArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "WAF_WEB_ACL_ARN: $$WAF_WEB_ACL_ARN" && \
	LAMBDA_EDGE_FUNCTION_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='LambdaEdgeFunctionArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "LAMBDA_EDGE_FUNCTION_ARN: $$LAMBDA_EDGE_FUNCTION_ARN" && \
	LAMBDA_EDGE_VERSION_ARN=$$(aws lambda list-versions-by-function \
	--function-name $$LAMBDA_EDGE_FUNCTION_ARN \
	--query "Versions[?Version!='$$LATEST'] | [-1].FunctionArn" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "LAMBDA_EDGE_VERSION_ARN: $$LAMBDA_EDGE_VERSION_ARN" && \
	make deploy aws_profile=$(aws_profile) stage=$(stage) region=$(region) WAF_WEB_ACL_ARN=$$WAF_WEB_ACL_ARN LAMBDA_EDGE_VERSION_ARN=$$LAMBDA_EDGE_VERSION_ARN

.PHONY: create_domain
create_domain:
	docker compose exec sls-deploy serverless create_domain --stage $(stage) --region $(region) --aws-profile $(aws_profile) --param="WAF_WEB_ACL_ARN=dummy" --param="LAMBDA_EDGE_VERSION_ARN=dummy"

.PHONY: delete_domain
delete_domain:
	docker compose exec sls-deploy serverless delete_domain --stage $(stage) --region $(region) --aws-profile $(aws_profile) --param="WAF_WEB_ACL_ARN=dummy" --param="LAMBDA_EDGE_VERSION_ARN=dummy"

.PHONY: remove
remove:
	docker compose exec sls-deploy serverless remove --stage $(stage) --region $(region) --aws-profile $(aws_profile) --param="WAF_WEB_ACL_ARN=$(WAF_WEB_ACL_ARN)" --param="LAMBDA_EDGE_VERSION_ARN=$(LAMBDA_EDGE_VERSION_ARN)"

.PHONY: remove-global
remove-global:
	docker compose exec sls-deploy serverless remove --config serverless-global.yml --stage $(stage) --region us-east-1 --aws-profile $(aws_profile)

.PHONY: remove-all
remove-all:
	WAF_WEB_ACL_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='WafWebAclArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "WAF_WEB_ACL_ARN: $$WAF_WEB_ACL_ARN" && \
	LAMBDA_EDGE_VERSION_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='LambdaEdgeFunctionArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "LAMBDA_EDGE_VERSION_ARN: $$LAMBDA_EDGE_VERSION_ARN" && \
	make remove aws_profile=$(aws_profile) stage=$(stage) region=$(region) WAF_WEB_ACL_ARN=$$WAF_WEB_ACL_ARN LAMBDA_EDGE_VERSION_ARN=$$LAMBDA_EDGE_VERSION_ARN
	make remove-global aws_profile=$(aws_profile) stage=$(stage)
	make delete_domain aws_profile=$(aws_profile) stage=$(stage)

.PHONY: remove-all-include-content
remove-all-include-content:
	make empty aws_profile=$(aws_profile) stage=$(stage)
	WAF_WEB_ACL_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='WafWebAclArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "WAF_WEB_ACL_ARN: $$WAF_WEB_ACL_ARN" && \
	LAMBDA_EDGE_VERSION_ARN=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-global-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='LambdaEdgeFunctionArn'].OutputValue" \
	--output text \
	--region us-east-1 \
	--profile $(aws_profile)) && \
	echo "LAMBDA_EDGE_VERSION_ARN: $$LAMBDA_EDGE_VERSION_ARN" && \
	make remove aws_profile=$(aws_profile) stage=$(stage) region=$(region) WAF_WEB_ACL_ARN=$$WAF_WEB_ACL_ARN LAMBDA_EDGE_VERSION_ARN=$$LAMBDA_EDGE_VERSION_ARN
	make remove-global aws_profile=$(aws_profile) stage=$(stage)
	make delete_domain aws_profile=$(aws_profile) stage=$(stage)

.PHONY: empty
empty:
	S3_BUCKET1_NAME=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='S3Bucket1Name'].OutputValue" \
	--output text \
	--region ap-northeast-1 \
	--profile $(aws_profile)) && \
	echo "S3_BUCKET1_NAME: $$S3_BUCKET1_NAME" && \
	docker compose exec sls-deploy aws s3 rm s3://$$S3_BUCKET1_NAME --recursive --profile $(aws_profile)
	S3_BUCKET2_NAME=$$(aws cloudformation describe-stacks \
	--stack-name pj-name-serverless-$(stage) \
	--query "Stacks[0].Outputs[?OutputKey=='S3Bucket2Name'].OutputValue" \
	--output text \
	--region ap-northeast-1 \
	--profile $(aws_profile)) && \
	echo "S3_BUCKET2_NAME: $$S3_BUCKET2_NAME" && \
	docker compose exec sls-deploy aws s3 rm s3://$$S3_BUCKET2_NAME --recursive --profile $(aws_profile)


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
