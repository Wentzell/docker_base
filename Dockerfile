FROM ubuntu:17.04

# Set up basic packages
RUN apt-get update
RUN apt-get install -y man-db locales git vim tmux zsh x11-xkb-utils software-properties-common

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# Set the working directory to /root
WORKDIR /root

# Set up compilers
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y 'deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-5.0 main'
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated g++-7 clang-5.0
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-5.0 60 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-5.0

## Set up additional packages
ADD pkglst /root
RUN apt-get --assume-yes install $(cat pkglst)

# Add user demo and switch
RUN useradd -m demo

# Copy code samples
ADD samples /home/demo/samples
RUN chown demo:demo -R /home/demo/samples

# Set up config for demo user
USER demo
WORKDIR /home/demo
RUN git clone http://github.com/Wentzell/dotfiles
WORKDIR /home/demo/dotfiles
RUN git checkout ubuntu
RUN git submodule init
RUN git submodule update
RUN ./link.sh
WORKDIR /home/demo
RUN git clone http://github.com/altercation/vim-colors-solarized /home/demo/.vim/bundle/vim-colors-solarized
RUN vim +VundleInstall +qall &> /dev/null
ADD debugging /home/demo/

CMD ["/usr/bin/zsh"]
