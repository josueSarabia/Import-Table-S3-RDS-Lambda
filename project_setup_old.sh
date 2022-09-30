#!/bin/bash

echo "Starting script..."

# region=us-east-1
rds_identifier=personsdb
secret_name=database_pw
s3_bucket=sfs-misc-data
account_number=$(aws sts get-caller-identity --query "Account" --output text)

# echo "Creating Security Group"
# aws ec2 create-security-group --group-name postgresql --description "Open Postgres for incoming traffic"

# sg_id=$(aws ec2 describe-security-groups --group-names "postgresql" --query "SecurityGroups[*].[GroupId]" --output text)

# echo $sg_id

# echo "opening port 5432 for postgres connection"
# aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 5432 --cidr 0.0.0.0/0

echo "Generating secure password"
password=$(pwgen 20 -sn1)

#echo "uploading password to SecretsManager"
#aws secretsmanager create-secret --name $secret_name --secret-string $password --region $region

# echo "Creating the RDS"
# aws rds create-db-instance \
    # --db-name postgres \
    # --db-instance-identifier $rds_identifier \
    # --engine postgres \
    # --master-username postgres \
    # --master-user-password $password \
    # --publicly-accessible \
    # --db-instance-class db.t3.micro \
    # --storage-type gp2 \
    # --enable-iam-database-authentication \
    # --region $region \
    # --allocated-storage 20 \
    # --vpc-security-group-ids $sg_id > info

# echo "creating Policy and role"
# aws iam create-policy \
#    --policy-name rds-s3-import-policy \
#    --policy-document '{
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Sid": "s3import",
#          "Action": [
#            "s3:GetObject",
#            "s3:ListBucket"
#          ],
#          "Effect": "Allow",
#          "Resource": [
#            "arn:aws:s3:::'$s3_bucket'", 
#            "arn:aws:s3:::'$s3_bucket'/*"
#          ] 
#        }
#      ] 
#    }' >> info

# aws iam create-role \
#    --role-name rds-s3-import-role \
#    --assume-role-policy-document '{
#      "Version": "2012-10-17",
#      "Statement": [
#        {
#          "Effect": "Allow",
#          "Principal": {
#             "Service": "rds.amazonaws.com"
#           },
#          "Action": "sts:AssumeRole",
#          "Condition": {
#              "StringEquals": {
#                 "aws:SourceArn": "arn:aws:rds:'$region':'$account_number':db:'$rds_identifier'"
#                 }
#              }
#        }
#      ] 
#    }' >> info

# echo "attach role and policy"
# aws iam attach-role-policy \
#    --policy-arn arn:aws:iam::$account_number:policy/rds-s3-import-policy \
#    --role-name rds-s3-import-role

# state="creating"
# until [[ "available" = "$state" ]]
# do
    # state=$(aws rds describe-db-instances --db-instance-identifier $rds_identifier --query "DBInstances[*].[DBInstanceStatus]" --output text)
    # echo "waiting for db to become available..."
    # echo "Status: $state"\n
    # sleep 30;
# done;

# echo "Add the IAM role to the RDS instance"
# aws rds add-role-to-db-instance \
#   --db-instance-identifier $rds_identifier \
#    --feature-name s3Import \
#   --role-arn arn:aws:iam::$account_number:role/rds-s3-import-role \
#   --region $region

endpoint=$(aws rds describe-db-instances --db-instance-identifier personsdb --query "DBInstances[*].Endpoint.Address" --output text)

echo endpoint

echo "Complete!"

rm info

printf "$endpoint\n$password\n$s3_bucket" | tee info