# Docker of anaconda with pytorch, tmux, zsh.


## Installation

Suppose you have cuda already installed, and cuda version is `cuda-9.0`, now you can go ahead with the following steps.

```bash
# download this repo
$ git clone https://github.com/richardbaihe/pytorch_docker.git
$ cd pytorch_docker
```

### 1 install docker and nvidia-docker

```bash
# 1. install docker
$ curl -fsSL get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh --mirror Aliyun
# add user to docker group if you do not want sudo every time
$ sudo usermod -aG docker runoob 
$ systemctl enable docker
$ service docker start
# check if docker is installed successfully
$ docker run hello-world 

# 2. install nvidia-docker and nvidia-docker-plugin

# If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
$ docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
$ sudo apt-get purge -y nvidia-docker
# Add the package repositories
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    sudo apt-key add -
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
$ sudo apt-get update

# Install nvidia-docker2 and reload the Docker daemon configuration
$ sudo apt-get install -y nvidia-docker2
$ sudo pkill -SIGHUP dockerd

# Test nvidia-smi with the latest official CUDA image
$ docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
```


### 2 build docker image

- if you want a quick start, you can pull the image from docker hub and skip the build step
```bash
# pull from docker hub directly
$ docker pull richardbaihe/pytorch:gpu
# check
$ docker image ls
```

- otherwise you need build your own image
- keep in mind that all user name in zshrc and Dockerfile should be replace from "baihe" to your desired name
```bash
$ docker build -t pytorch:gpu -f Dockerfile .

# it will take a while, please wait...

$ docker image ls
REPOSITORY              TAG         IMAGE ID            CREATED             SIZE
pytorch                 gpu         70fbd709e31e        3 minutes ago       9.76GB
hello-world             latest      fce289e99eb9        20 minutes ago      1.84kB

```


### 3 start a container

- Here, I prepare a datasets folder, a checkpoints folder and a projects folder to synchronize data 
between local file system and docker file system.

```bash
# start a container
$ docker container run -it \
    --name gpu_env \
    --runtime=nvidia -u baihe \
    --mount type=bind,source=/data/baihe/datasets,target=/home/baihe/datasets \
    --mount type=bind,source=/data/baihe/projects,target=/home/baihe/projects \
    --mount type=bind,source=/data/baihe/checkpoints,target=/home/baihe/checkpoints \
    --shm-size=16g richardbaihe/pytorch:gpu /bin/zsh
```

### 4 Create a user in the container
If you pull the pre-built docker image directly from the docker hub, then the 
default user would be baihe and the password is richarddbaihe. To create
a user for yourself, run the following command.
```bash
sudo useradd --create-home --no-log-init --shell /bin/zsh $USERNAME
sudo adduser $USERNAME sudo
sudo passwd $USERNAME
su - $USERNAME

```