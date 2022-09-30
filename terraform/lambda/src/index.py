import psycopg2
from aws_lambda_powertools.utilities import parameters
from botocore.config import Config
import os

def lambda_handler(event, context):
    region = os.environ("region")
    secret_name = os.environ("secret_name")
    rds_host = os.environ("rds_host")
    bucket_name = os.environ("bucket_name")

    config = Config(region_name="us-east-1")

    secrets_provider = parameters.SecretsProvider(config=config)

    value = secrets_provider.get({secret_name})

    print(event)

    conn = psycopg2.connect(f"host={rds_host} dbname=postgres user=postgres password={value}")

    cursor = conn.cursor()

    cursor.execute("select count(*) from pg_extension where extname = 'aws_s3';")
    installed = cursor.fetchone()

    if installed and installed[0] == 0:
        cursor.execute("CREATE EXTENSION aws_s3 CASCADE;")

    cursor.execute(f"DROP TABLE IF EXISTS persons; CREATE TABLE persons \
(id SERIAL PRIMARY KEY, first_name varchar(80), title varchar(80), location varchar(80)); \
SELECT aws_s3.table_import_from_s3('persons','','(format csv)','({bucket_name}, \
data.csv,{region})');")

    conn.commit()

    cursor.close()
    conn.close()