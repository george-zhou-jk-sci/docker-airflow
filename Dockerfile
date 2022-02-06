FROM apache/airflow:2.2.3-python3.8

USER root

ENV DEBUAN_FRONTEND=noninteractive
ENV TERM=linux

ENV AIRFLOW_HOME=${AIRFLOW_HOME}
ENV DAGS_FOLDER=dags/repo/dags
ENV PYTHONPATH=$${AIRFLOW_HOME}/${DAGS_FOLDER}:${AIRFLOW_HOME}

ENV AWS_DEFAULT=us-east-1


RUN apt-get update -yqq \
  && apt-get upgrade -yqq \
  && apt-get install -y --no-install-recommends \
        python3-pip \
        python3-requests \
        apt-utils \
        curl \
        zip \
        unzip \
         vim \
         nano \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow

COPY requirements.txt ${AIRFLOW_HOME}

RUN pip install --user -r ${AIRFLOW_HOME}/requirements.txt \
    &&  pip install --user apache-airflow[crypto,postgres,aws,kubenetes]==2.2.3 \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.2.3/constraints-3.8.txt"
    
RUN pip list > ${AIRFLOW_HOME}/log.txt
