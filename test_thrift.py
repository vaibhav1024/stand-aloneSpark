import jaydebeapi
import jpype

jar = '/opt/spark/SparkJDBC41.jar' # location of the jdbc driver jar
args='-Djava.class.path=%s' % jar
jvm = jpype.getDefaultJVMPath()
jpype.startJVM(jvm, args)

sp = jaydebeapi.connect('com.simba.spark.jdbc41.Driver','jdbc:spark://localhost:10000/default2;AuthMech=3;',['simba','simba'])


#jaydebeapi.connect('com.simba.spark.jdbc41.Driver','jdbc:spark://dbc-06c5f9df-a762.cloud.databricks.com:443/default;transportMode=http;ssl=1;AuthMech=3;httpPath=/sql/1.0/endpoints/cc5b8e2cf2877bdb;',[]

spCur = sp.cursor()
spCur.execute("SHOW DATABASES;")

tables = spCur.fetchall()

sp.close()
tableList = []
for table in tables:
        tableList.append(str(table[0]))

print(tableList)
