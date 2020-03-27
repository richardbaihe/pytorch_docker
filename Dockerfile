ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:19.07-py3 
FROM $BASE_IMAGE                                                                        
MAINTAINER richardbaihe <h32bai@uwaterloo.ca>                                                                 
ENV HOME=/home/baihe USER=baihe ANACONDA_HOME=/home/baihe/anaconda3                                            
USER root                                                                                                
# add user                                                                                               
RUN useradd --create-home --no-log-init --shell /bin/zsh $USER \                                         
    && adduser $USER sudo \                                                                              
    && echo 'baihe:richardbaihe' | chpasswd                                                    

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
                                                                                                         
USER $USER
RUN chmod 777 $HOME
WORKDIR $HOME
COPY ./requirements.txt $HOME/                                                 

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
# anaconda and pip packages
# ===============
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh \
    && /bin/sh ~/anaconda.sh -b -p $ANACONDA_HOME \                                                      
    && rm ~/anaconda.sh \                                                                                
    && export PATH=$HOME/anaconda3/bin:$PATH \                           
    && pip install --no-cache-dir -r requirements.txt         

# ===========
# latest apex
# ===========
RUN echo "Installing Apex on top of ${BASE_IMAGE}"
RUN pip uninstall -y apex && \
git clone https://github.com/NVIDIA/apex.git ~/apex && \
cd ~/apex && \
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .

CMD ["/bin/zsh"]
