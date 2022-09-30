#!/bin/bash

# read terraform action (init, apply, destroy)
if [[ $# == 1 && ($1 == "init" || $1 == "apply" || $1 == "destroy") ]]
then
    action=$1
else
    echo "unknown argmuent with value $1. available options: init, apply, destroy."
    exit 1
fi

echo "Starting script..."
region = "us-east-1"
profile = "josue.sarabia"
bucket_name = "rds-data-bucket"
account_number=$(aws sts get-caller-identity --query "Account" --output text)
secret_name = "rdspassword"
db_identifier = "personsdb"


if [[ $action == "init" ]]
then
    echo "init s3 bucket"
    terraform -chdir=./terraform/s3/ init

    echo "init secret"
    terraform -chdir=../secrets/ init

    echo "init rds"
    terraform -chdir=../rds/ init

    echo "init lambda"
    terraform -chdir=../lambda/ init
else
    echo "Generating secure password"
    password=$(pwgen 20 -sn1)

    echo "$action s3 bucket"
    terraform -chdir=./terraform/s3/ $action -var "name=$bucket_name" -var "region=$region" -var "profile=$profile" -auto-approve

    echo "$action secret"
    terraform -chdir=../secrets/ $action -var "name=$secret_name" -var "value=$password" -var "region=$region" -var "profile=$profile" -auto-approve

    echo "$action rds"
    terraform -chdir=../rds/ $action -var "identifier=$db_identifier" -var "password=$password" -var "s3_bucket=$bucket_name" \
        -var "region=$region" -var "profile=$profile" -var "account_number=$account_number" -auto-approve

    echo "get rds endpoint"
    endpoint=$(aws rds describe-db-instances --db-instance-identifier $db_identifier --query "DBInstances[*].Endpoint.Address" --output text)

    echo "installing python packages"
    mkdir -p ./terraform/lambda/python/lib/python3.8/site-packages/
    pip3 install boto3 psycopg2-binary aws_lambda_powertools -t ./terraform/lambda/python/lib/python3.8/site-packages/

    echo "$action lambda"
    terraform -chdir=../lambda/ $action -var "bucket_name=$bucket_name" -var "secret_name=$secret_name" -var "rds_host=$endpoint" \
        -var "region=$region" -var "profile=$profile" -auto-approve

    echo endpoint

    echo "Complete!"

    printf "$endpoint\n$password" | tee info
fi
