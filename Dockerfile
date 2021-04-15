# VERSION 2.0.1
# AUTHOR: bigshane
# DESCRIPTION: Airflow container
# BUILD: docker build -t bigshane/docker-airflow:2.0.1 .
# SOURCE:

FROM ubuntu:18.04
LABEL maintainer="bigshane_"

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive \
    TERM linux

# Airflow
ARG AIRFLOW_VERSION=2.0.1 \
    AIRFLOW_USER_HOME=/root/airflow \
    AIRFLOW_DEPS="datadog,dask" \
    TIMEZONE="utc"
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME} \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL=0 \
    AIRFLOW__SCHEDULER__CATCHUP_BY_DEFAULT=False \
    AIRFLOW__EMAIL__DEFAULT_EMAIL_ON_RETRY=False \
    AIRFLOW__EMAIL__DEFAULT_EMAIL_ON_FAILURE=False \
    AIRFLOW__CORE__DEFAULT_TIMEZONE=${TIMEZONE} \
    AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE=${TIMEZONE} \
    PATH=~/.cargo/bin:${PATH}

COPY config/airflow.cfg config/webserver_config.py ${AIRFLOW_USER_HOME}/
COPY script/entrypoint.sh /

EXPOSE 8080 5555 8793

RUN set -ex \
    && buildDeps=' \
        freetds-bin \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        git \
        curl \
        rsync \
        netcat \
        locales \
        software-properties-common \
    ' \
    && buildPython=' \
        python-setuptools \
        python3-setuptools \
        python-pip \
        python3-pip \
        python3-dev \
        python3.7-dev \
    ' \
    && buildAirflowDeps=' \
        pytz \
        pyOpenSSL \
        ndg-httpsclient \
        pyasn1 \
        flask_oauthlib>=0.9 \
        typing_extensions \
    ' \
    && apt update -yqq \
    && apt upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
    && apt-get install -y python3.7 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1 \
    && apt-get install -yqq \
        $buildPython \
    && pip3 install --upgrade pip==20.2.4 \
    && apt update -yqq \
    && apt upgrade -yqq \
    && apt-get install -y wget tzdata vim net-tools curl \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && pip3 install \
        $buildAirflowDeps \
    && pip3 install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip3 install SQLAlchemy==1.3.23 \
    && pip3 install 'redis==3.2' \
    && airflow db reset -y \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
