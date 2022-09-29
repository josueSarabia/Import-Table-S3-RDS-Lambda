import psycopg2
from aws_lambda_powertools.utilities import parameters
from botocore.config import Config

def lambda_handler(event, context):

    config = Config(region_name="us-east-1")

    secrets_provider = parameters.SecretsProvider(config=config)

    value = secrets_provider.get("rdspassword")

    print(event)

    conn = psycopg2.connect("host= RDS URL HOST dbname=postgress user=postgress password={}".format(value))

    conn.cursor().execute("DROP TABLE IF EXISTS persons; CREATE TABLE persons \
(id SERIAL PRIMARY KEY, first_name varchar(80), title varchar(80), location varchar(80)); \
SELECT aws_s3.table_import_from_s3('persons','','(format csv)','(NOMBRE DEL BUCKET, \
NOMBRE DEL ARHIVO.csv, REGION QUE QUIERAS)');")

    conn.commit()