FROM ubuntu:jammy
ARG LLVM=13

## Set up additional packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
        vim \
        neovim \
        tmux \
        zsh \
        sudo \
        wget \
        make \
        cmake \
        ninja-build \
        ccache \
        software-properties-common \
        locales \
        gpg-agent \
        openssh-server \
        x11-xkb-utils \
        less \
        man-db \
        g++ \
        valgrind \
        gdb \
        cppcheck \
        clang-${LLVM} \
        clangd-${LLVM} \
        clang-format-${LLVM} \
        clang-tidy-${LLVM} \
        llvm \
        lldb-${LLVM} \
        libc++-${LLVM}-dev \
        libc++abi-${LLVM}-dev \
        libomp-${LLVM}-dev \
        libclang-${LLVM}-dev \
        python3-clang-${LLVM} \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-lldb-${LLVM} && \
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Use LLVM-13 by default
RUN for i in lldb clang clang++ clang-tidy clangd; do update-alternatives --install /usr/local/bin/$i $i /usr/bin/$i-${LLVM} 20; done

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set up user docker
ARG NB_USER=docker
ARG NB_UID=1000
RUN useradd -u $NB_UID -m $NB_USER && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $NB_USER
WORKDIR /home/$NB_USER

# Set up config files
RUN git clone --recursive http://github.com/Wentzell/dotfiles
WORKDIR /home/$NB_USER/dotfiles
RUN git checkout ubuntu
RUN ./link.sh
WORKDIR /home/$NB_USER
RUN git clone http://github.com/altercation/vim-colors-solarized /home/$NB_USER/.vim/bundle/vim-colors-solarized
RUN vim +PlugInstall +qall &> /dev/null

CMD ["/usr/bin/zsh", "-l"]
