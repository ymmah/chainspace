#!/bin/sh

ECS_REGISTRY="987195267860.dkr.ecr.eu-west-1.amazonaws.com"
APP_NAME="chainspace/app"
CLUSTER_NAME="chainspace"

set_version() {
  VERSION="latest"
}

set_image_tag() {
  echo "  - set_image_tag"
  DOCKER_IMAGE_TAG="$APP_NAME:$VERSION"
}

build() {
  echo "  - build"
  set_version
  set_image_tag
  docker build -t ${DOCKER_IMAGE_TAG} .
}

push() {
  echo "Login into AWS ECS registry"
  login=$(aws ecr get-login --region eu-west-1 --no-include-email)
  $login
  eval "docker tag ${DOCKER_IMAGE_TAG} ${ECS_REGISTRY}/${DOCKER_IMAGE_TAG}"
  eval "docker push ${ECS_REGISTRY}/${DOCKER_IMAGE_TAG}"
  echo "Tagged and pushed image to ECS registry as $ECS_REGISTRY/$DOCKER_IMAGE_TAG"
  # docker_cleanup
}

docker_cleanup() {
  docker images | grep $APP_NAME | awk '{ print $3; }' | xargs docker rmi -f
  echo "Deleted the Docker image ${DOCKER_IMAGE_TAG} from the GoCd Agent"
}

ecs_restart() {
  TASK=$(aws ecs list-tasks --cluster chainspace | jq '.taskArns[0]')
  CONTAINER=$(aws ecs  list-container-instances --cluster chainspace | jq .containerInstanceArns[0])
  echo $TASK
  echo $CONTAINER

  eval "aws ecs  stop-task --cluster chainspace --task ${TASK}"
  sleep 5

  eval "aws ecs start-task --cluster chainspace --task-definition arn:aws:ecs:eu-west-1:987195267860:task-definition/chainspace-app4:8  --container-instance ${CONTAINER}"

  sleep 5
}

build
push
ecs_restart
