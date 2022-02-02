FROM apache/airflow

# Arguments that can be set with docker build
ARG AIRFLOW_DEFAULT_DAGS=False
ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW_CUSTOM_MODULES=/opt/airflow/custom_modules
ARG AIRFLOW_DAGS=/opt/airflow/dags
ARG ASSETS_DIR=/tmp/assets

# Environment variables
ENV AIRFLOW_HOME=${AIRFLOW_HOME}
ENV AIRFLOW__CORE__LOAD_EXAMPLES=${AIRFLOW_DEFAULT_DAGS}
ENV PYTHONPATH=${PYTHONPATH}:${AIRFLOW_CUSTOM_MODULES}
ENV ASSETS_DIR=${ASSETS_DIR}
ENV PG_QUERY_PATH=${ASSETS_DIR}/create_schema_and_table.sql

# Create directory for assets
USER root
RUN mkdir -p ${ASSETS_DIR}
USER airflow

# Install packages (vim)
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         vim \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow


# Place dags and custom modules in right place
COPY --chown=airflow:root ./dags ${AIRFLOW_DAGS}
COPY --chown=airflow:root ./custom_modules ${AIRFLOW_CUSTOM_MODULES}

# Place assets in right place
COPY --chown=airflow:root ./assets ${ASSETS_DIR}

# Expose ports (just to indicate that this container needs to map port)
EXPOSE 8080

