# Running Spark Locally

## Pre-requisites

- [Docker](https://www.docker.com/)
- [JDK 11](https://openjdk.java.net/projects/jdk/11/)

## Installing Java JDK 11

```shell
sudo apt update
sudo apt install openjdk-11-jdk

java --version
```
## Running Docker Compose

The Docker image used is the [Bitnami Spark](https://hub.docker.com/r/bitnami/spark/).

```shell
docker-compose up
```