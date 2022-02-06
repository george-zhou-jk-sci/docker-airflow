set -e

DOCKER_TAG=0.0.1.0

docker build -t 467326414092.dkr.ecr.us-east-1.amazonaws.com/docker-airflow:${DOCKER_TAG} . >> deploy.log

docker push 467326414092.dkr.ecr.us-east-1.amazonaws.com/docker-airflow:${DOCKER_TAG}