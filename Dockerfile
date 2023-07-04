FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    nano \
    sudo \
    systemctl \
    lsb-core \
    curl \
    unzip \
    openjdk-8-jre-headless \
    openjdk-8-jdk

#install postgresql
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - 

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Ho_Chi_Minh

RUN apt-get update && apt-get install -y postgresql-12
#create user for airflow
USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE DATABASE airflow_db;" \
    && psql --command "CREATE USER airflow WITH PASSWORD 'airflow';" \
    && psql --command "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow;" \
    && psql --command "ALTER USER airflow SET search_path = public;" \
    && psql --command "GRANT ALL ON SCHEMA public TO airflow;"

USER root
#install awscliv2 & apache-spark
RUN cd /home \
    && mkdir Downloads \
    && cd Downloads \
    #get awscliv2
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    #get spark
    && wget https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz \
    # get kafka 
    && wget https://archive.apache.org/dist/kafka/3.2.0/kafka_2.12-3.2.0.tgz \
    #extract awscliv2.zip
    && unzip awscliv2.zip \
    #extract spark
    && tar xvzf spark-3.4.1-bin-hadoop3.tgz \
    #extract kafka 
    && tar xzf kafka_2.12-3.2.0.tgz \
    #move spark to /usr/spark
    && mv spark-3.4.1-bin-hadoop3 /usr/spark \
    #move aws to /usr/aws
    && mv aws /usr/aws \
    #move kafka to /usr/kafka 
    && mv kafka_2.12-3.2.0 /usr/kafka \ 
    #install aws 
    && sudo /usr/aws/install \ 
    # install  virtualenv
    && pip install virtualenv

# set path for spark 
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME=/usr/spark
ENV KAFKA_HOME=/usr/kafka
ENV PATH=$PATH:$SPARK_HOME/bin
ENV PATH=$PATH:$KAFKA_HOME/bin
ENV PYSPARK_PYTHON=/usr/bin/python3.10
ENV PYSPARK_DRIVER_PYTHON=/usr/bin/python3.10
ENV AIRFLOW_HOME=/root/airflow
#delete folder Downloads to reduce size of images
RUN rm -r /home/Downloads
WORKDIR /app/
#create virtualenv for airflow
RUN mkdir airflow_workspace \
    && cd airflow_workspace \
    && virtualenv airflow_env 
RUN mkdir dbt_environment \
    && cd dbt_environment \
    && virtualenv dbt_env
#copy file from host to images
COPY requirements.txt /app/requirements.txt
COPY dbt_requirements.txt /app/dbt_requirements.txt
COPY zookeeper.service /etc/systemd/system/zookeeper.service
COPY kafka.service /etc/systemd/system/kafka.service
COPY start_system.sh /app/airflow_workspace/start_system.sh
##install airflow into airflow_environment
RUN ./airflow_workspace/airflow_env/bin/pip install -r requirements.txt
#install dbt into dbt_environment
RUN ./dbt_environment/dbt_env/bin/pip install -r dbt_requirements.txt

# remove file to reduce size of images
RUN rm /app/requirements.txt dbt_requirements.txt
# move config file airflow
COPY airflow.cfg /root/airflow/airflow.cfg
#create dags folder
RUN mkdir /root/airflow/dags

RUN echo "source /app/airflow_workspace/airflow_env/bin/activate" >> ~/.bashrc
WORKDIR /app
RUN chmod +x /app/airflow_workspace/start_system.sh


CMD ["/bin/bash"]
