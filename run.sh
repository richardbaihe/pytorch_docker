docker container run -itd \
    --name gpu_env \
    --runtime=nvidia -u baihe \
    --mount type=bind,source=/data/baihe/dataset,target=/home/baihe/dataset \
    --mount type=bind,source=/data/baihe/checkpoints,target=/home/baihe/checkpoints \
    --shm-size=16g richardbaihe/pytorch:gpu /bin/zsh \
|| \
docker container exec -it gpu_env /bin/zsh
