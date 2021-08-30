# Docker of pytorch with zsh/vim/apex/ssh-login development environment


## Quick start

```bash
$ docker pull richardbaihe/pytorch:lastest
$ docker container run -itd  --name test_env  --mount type=bind,source=/data/projects/,target=/root/projects --mount type=bind,source=/data/datasets/,target=/root/datasets --mount type=bind,source=/data/checkpoints/,target=/root/checkpoints   --shm-size=16g richardbaihe/pytorch:lastest /bin/zsh
$ docker attach test_env
```

## Build your own docker image

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

```bash
$ docker build -t pytorch:test -f Dockerfile .

# it will take a while, please wait...

$ docker image ls
REPOSITORY              TAG         IMAGE ID            CREATED             SIZE
pytorch                 gpu         70fbd709e31e        3 minutes ago       9.76GB
hello-world             latest      fce289e99eb9        20 minutes ago      1.84kB

```
