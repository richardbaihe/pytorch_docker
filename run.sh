docker container run -itd \
    --name gpu_env \
    --runtime=nvidia -u pzq \
    --mount type=bind,source=/path/to/data,target=/home/pzq/Desktop/data \
    --mount type=bind,source=/path/to/code,target=/home/pzq/Desktop/code \
    --shm-size=16g pytorch_tf:gpu /bin/zsh \
|| \
docker container exec -it gpu_env /bin/zsh