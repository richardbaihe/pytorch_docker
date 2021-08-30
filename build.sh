docker build -t pytorch:gpu -f Dockerfile .

docker rmi $(docker images -f "dangling=true" -q)

docker container run -itd  --name h32bai_lastest  --mount type=bind,source=/data/h32bai/projects/,target=/root/projects --mount type=bind,source=/data/h32bai/datasets/,target=/root/datasets --mount type=bind,source=/data/h32bai/checkpoints/,target=/root/checkpoints   --shm-size=16g richardbaihe/pytorch:lastest /bin/zsh

docker inspect -f "{{ .NetworkSettings.IPAddress }}" Container_Name