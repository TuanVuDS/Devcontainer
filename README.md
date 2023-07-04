# Devcontainer
First, you need to run the **start_system.sh** file. If you haven't done so, please run the command:

                                                              bash start_system.sh

# START AIRFLOW
To start using Airflow, make sure you have executed the **_start_system.sh_** file. The default environment is **_airflow_env_**. If you are in a different environment, please run the command to switch to the Airflow environment:

                                            source /app/airflow_workspace/airflow_env/bin/activate


First, run the command: **airflow db init** (only run once). After it finishes, please set up an Airflow account using the following command:


     airflow users create --username your_username --firstname your_first_name --lastname your_last_name --role Admin --email your_email --password your_password

Once you have created the Airflow account, proceed to run the command: **"airflow scheduler"**. Then, open another terminal and run the command: **"airflow webserver"**. You can interact with Airflow through the URL **_localhost:8080_**

Airflow's folder : **_/root/airflow_** . You can use command to view and config by yourself:

                                                            cd /root/airflow 


# START PYSPARK-SHELL
Simply enter **"pyspark"** in the **terminal** to start using it. You can check the information of PySpark using the command:

                                                              cd /usr/spark

# START KAFKA
When running **start_system.sh** above, **Kafka** and **ZooKeepe**r are already **running**, and you can interact with them immediately. Additionally, you can configure Kafka according to your needs at: 

                                                              cd /usr/kafka

# SQLALCHEMY
SQLAlchemy is **already** integrated into the **_airflow_env_**. Make **sure** you are in the **_airflow_env_** environment by running the command:

                                          source /app/airflow_workspace/airflow_env/bin/activate

# DBT (DATA BUILD TOOL)
To use DBT, please run the command to switch to the DBT environment and proceed with working with DBT:

                                              source /app/dbt_environment/dbt_env/bin/activate
