ARG BASE_IMAGE=pytorch/pytorch:1.8.0-cuda11.1-cudnn8-devel
FROM $BASE_IMAGE                                                                        
MAINTAINER richardbaihe <h32bai@uwaterloo.ca>                                                                 
ENV HOME=/root               
USER root       
WORKDIR $HOME                                                                                            

# ===============
# system packages
# ===============
RUN apt-get update \                                                                                  
    && apt-get install -y gcc locales zsh ssh git curl libx11-6 libncurses5-dev tmux wget bzip2 sudo vim software-properties-common \   
    && rm -rf /var/lib/apt/lists/* \                                                                     
    && chsh -s /bin/zsh    

# ===========
# latest apex
# ===========
RUN echo "Installing Apex on top of ${BASE_IMAGE}"
# uninstall Apex if present, twice to make absolutely sure :)
RUN pip uninstall -y apex || :
# SHA is something the user can touch to force recreation of this Docker layer,
# and therefore force cloning of the latest version of Apex
RUN SHA=ToUcHMe git clone https://github.com/NVIDIA/apex.git
# COPY ./setup.py $HOME/apex/setup.py
WORKDIR $HOME/apex
RUN pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
WORKDIR $HOME
  

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8                

# ===============
# ohmyzsh and vim
# ===============
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \     
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/amix/vimrc.git ~/.vim_runtime \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh
COPY ./zshrc $HOME/.zshrc

# ===============
# pip packages
# ===============
RUN pip install nltk
RUN python -m nltk.downloader punkt wordnet
RUN pip install wandb
RUN echo $PATH


RUN apt-get update && apt-get install -y openssh-server sudo
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22


CMD ["/bin/zsh"]

