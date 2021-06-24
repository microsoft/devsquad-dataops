# dataopslib

## Prerequisites

- Python 3.x
- Docker + Docker Compose

## Getting Started

Create a virtual environment and install the required packages:

```sh
python3 -m venv dataopslib_env
source dataopslib_env/bin/activate

pip3 install -r requirements.txt
```

### **Running Apache Spark locally with Docker**

Open the `spark` folder on your terminal and run the Docker compose to start an Apache Spark instance locally:

```sh
docker-compose up
```

### **Running samples**

Open the sample files located in the `samples` directory on Visual Studio Code and run the project.

### **Deactivating the virtual environment**

```sh
deactivate
```

### **Building and testing the samples**

```sh
flake8 ./dataopslib ./samples ./tests
pytest --ignore=setup.py
python3 setup.py sdist bdist_wheel
```
