ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:20.06-py3
FROM $BASE_IMAGE                                                                        
MAINTAINER richardbaihe <h32bai@uwaterloo.ca>                                                                 
ENV HOME=/home/root USER=baihe ANACONDA_HOME=/opt/anaconda3
USER root

# ===============
# system packages
# ===============
RUN apt-get update \                                                                                  
    && apt-get install -y gcc locales zsh git curl libx11-6 libncurses5-dev tmux wget bzip2 sudo vim software-properties-common \   
    && rm -rf /var/lib/apt/lists/* \                                                                     
    && chsh -s /bin/zsh      

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# ===============
# anaconda and pip packages
# ===============
WORKDIR /tmp/docker
COPY ./requirements.txt /tmp/docker/
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O /tmp/docker/anaconda.sh \
    && /bin/sh /tmp/docker/anaconda.sh -b -p $ANACONDA_HOME \
    && rm /tmp/docker/anaconda.sh \
    && export PATH=$ANACONDA_HOME/bin:$PATH \
    && pip install --no-cache-dir -r /tmp/docker/requirements.txt \
    && python -m nltk.downloader punkt

# ===============
# vimrc
# ===============
RUN git clone --depth=1 https://github.com/amix/vimrc.git /opt/vim_runtime \
    && sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all

# ===============
# ohmyzsh
# ===============
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && cp -r ~/.oh-my-zsh /etc/skel/
COPY ./zshrc /etc/skel/.zshrc
RUN cp /etc/skel/.zshrc ~/.zshrc

# ===========
# latest apex
# ===========
RUN echo "Installing Apex on top of ${BASE_IMAGE}"
# make sure we don't overwrite some existing directory called "apex"
WORKDIR /tmp/unique_for_apex
# uninstall Apex if present, twice to make absolutely sure :)
RUN pip uninstall -y apex || :
RUN pip uninstall -y apex || :
# SHA is something the user can touch to force recreation of this Docker layer,
# and therefore force cloning of the latest version of Apex
RUN SHA=ToUcHMe git clone https://github.com/NVIDIA/apex.git
WORKDIR /tmp/unique_for_apex/apex
COPY ./setup.py /tmp/unique_for_apex/apex/
RUN pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .

# add user
RUN useradd --create-home --no-log-init --shell /bin/zsh $USER \
    && adduser $USER sudo \
    && echo 'baihe:richardbaihe' | chpasswd
WORKDIR /home/${USER}

CMD ["/bin/zsh"]
