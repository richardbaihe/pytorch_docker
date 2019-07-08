FROM nvidia/cuda:9.0-cudnn7-devel                                                                        
MAINTAINER ziqiang pei <dfzspzq@163.com>                                                                 
                                                                                                         
                                                                                                         
ENV HOME=/home/pzq USER=pzq ANACONDA_HOME=/home/pzq/anaconda3                                            
                                                                                                         
USER root                                                                                                
# add user                                                                                               
RUN useradd --create-home --no-log-init --shell /bin/zsh $USER \                                         
    && adduser $USER sudo \                                                                              
    && echo 'pzq:password' | chpassw                                                    

# install basic tools                                                             
RUN apt-get update \                                                                                  
    && apt-get install -y zsh git-core libevent-dev libncurses5-dev tmux git-all wget bzip2 sudo vim \   
    && rm -rf /var/lib/apt/lists/* \                                                                     
    && chsh -s /bin/zsh      
                                                                                                         
                                                                                                         
USER pzq                                                                                                 
WORKDIR $HOME
COPY ./requirements.txt $HOME/                                                 
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \     
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \                                                                                                                                
    && mkdir ~/Desktop ~/Downloads \                                                                     
    # for anaconda                                                                                       
    && wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh -O ~/anaconda.sh \
    && /bin/sh ~/anaconda.sh -b -p $ANACONDA_HOME \                                                      
    && rm ~/anaconda.sh \                                                                                
    && export PATH=$PATH:$HOME/anaconda3/bin \                                                           
    && pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple \                           
    && pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple        
                                                                                                         
                                                                                                         
VOLUME [""]

CMD ["/bin/zsh"]
