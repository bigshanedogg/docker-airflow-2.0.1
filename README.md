# docker-airflow-2.0.1

- This repository contains **Dockerfile** of [apache-airflow:2.0.1](https://github.com/apache/incubator-airflow) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bigshane/docker-airflow/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).
- Based on Ubuntu 18.04 official Image [ubuntu:18.04](https://hub.docker.com/_/ubuntu/)
- Mainly referred to [puckle/docker-airflow](https://hub.docker.com/r/puckel/docker-airflow), which is one of the most popular apache-airflow(<=1.10.9) images

## Installation

Pull the image from the Docker repository.

    docker pull  bigshane/docker-airflow:2.0.1
    
## Build

    docker build -t bigshane/docker-airflow:2.0.1 .
    
You can also use this to set timezone:

    docker build --build-arg TIMEZONE="Asia/Seoul" -t bigshane/docker-airflow:2.0.1 .

## Usage

this image runs Airflow only with **SequentialExecutor** :

    docker run --rm -d -p 8080:8080 -v ${your_path}/dags:/root/airflow/dags bigshane/docker-airflow:2.0.1 webserver

## UI Links

- Airflow: [localhost:8080](http://localhost:8080/)
- Flower: [localhost:5555](http://localhost:5555/)