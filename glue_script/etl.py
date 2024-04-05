import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, to_date
from awsglue.dynamicframe import DynamicFrame

# Create a GlueContext
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Initialize parameters
args = getResolvedOptions(sys.argv,
                          ['JOB_NAME',
                           'bucket',
                           'output_key'])

job.init(args['JOB_NAME'], args)

# Read JSON file from S3 and create DataFrame
json_df = spark.read.json("s3://{}/{}".format(args['bucket'], "dataset.json"))

# Date formatting
json_df_transformed = json_df.withColumn("Order Date", to_date(col("Order Date"), "dd-MM-yyyy"))
json_df_transformed = json_df_transformed.withColumn("Ship Date", to_date(col("Ship Date"), "dd-MM-yyyy"))

jsonDF = DynamicFrame.fromDF(json_df_transformed, glueContext, "jsonDF")

jsonDF = ApplyMapping.apply(
    frame=jsonDF,
    mappings=[
        ("Category", "string", "Category", "string"),
        ("City", "string", "City", "string"),
        ("Country", "string", "Country", "string"),
        ("Customer ID", "string", "Customer ID", "string"),
        ("Customer Name", "string", "Customer Name", "string"),
        ("Delivery Days", "long", "Delivery Days", "int"),
        ("Discount", "double", "Discount", "float"),
        ("Market", "string", "Market", "string"),
        ("Order Date", "date", "Order Date", "string"),
        ("Order ID", "string", "Order ID", "string"),
        ("Order Priority", "string", "Order Priority", "string"),
        ("Product ID", "string", "Product ID", "string"),
        ("Product Name", "string", "Product Name", "string"),
        ("Profit", "long", "Profit", "float"),
        ("Quantity", "long", "Quantity", "int"),
        ("Region", "string", "Region", "string"),
        ("Sales", "long", "Sales", "float"),
        ("Segment", "string", "Segment", "string"),
        ("Ship Date", "date", "Ship Date", "string"),
        ("Ship Mode", "string", "Ship Mode", "string"),
        ("Shipping Cost", "long", "Shipping Cost", "float"),
        ("State", "string", "State", "string"),
        ("Sub-Category", "string", "Sub-Category", "string"),
        ("", "long", "Unnamed: 0", "int"),
        ("order month", "long", "order month", "int"),
        ("order year", "long", "order year", "int")],
    transformation_ctx="orders_transformation")

# Write DataFrame to S3 and Glue Data Catalog as parquet file
output_path = "s3://{}/{}".format(args['bucket'], args['output_key'])

s3output = glueContext.getSink(
    path="s3://camesruiz-waddi/data/",
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=["order year"],
    compression="snappy",
    enableUpdateCatalog=True,
    transformation_ctx="s3_data",
)

s3output.setCatalogInfo(
    catalogDatabase="waddi", catalogTableName="orders"
)

s3output.setFormat("glueparquet")
s3output.writeFrame(jsonDF)

job.commit()
