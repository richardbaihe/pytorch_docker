FROM nvidia/cuda:10.1-base-ubuntu16.04                                                                        
MAINTAINER richardbaihe <h32bai@uwaterloo.ca>                                                                 
ENV HOME=/home/baihe USER=baihe ANACONDA_HOME=/home/baihe/anaconda3                                            
USER root                                                                                                
# add user                                                                                               
RUN useradd --create-home --no-log-init --shell /bin/zsh $USER \                                         
    && adduser $USER sudo \                                                                              
    && echo 'baihe:richardbaihe' | chpasswd                                                    

# install basic tools                                                             
RUN apt-get update \                                                                                  
    && apt-get install -y locales zsh git curl libx11-6 libncurses5-dev tmux wget bzip2 sudo vim \   
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
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \     
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/amix/vimrc.git ~/.vim_runtime \
    && sh ~/.vim_runtime/install_awesome_vimrc.sh
COPY ./zshrc $HOME/.zshrc
    # for anaconda                                                                                      
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh \
    && /bin/sh ~/anaconda.sh -b -p $ANACONDA_HOME \                                                      
    && rm ~/anaconda.sh \                                                                                
    && export PATH=$PATH:$HOME/anaconda3/bin \                           
    && pip install --no-cache-dir -r requirements.txt         
                                                                                                         
                                                                                                         

CMD ["/bin/zsh"]
