FROM osrf/ros:humble-desktop-full

ARG USERNAME=USERNAME
ARG PLATFORM_TYPE=PLATFORM_TYPE
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y python3-pip
ENV SHELL /bin/bash


ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV QT_X11_NO_MITSHM=1
ENV EDITOR=nano
ENV XDG_RUNTIME_DIR=/tmp

RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    libglu1-mesa-dev \
    nano \
    python3-pip \
    python3-pydantic \
    ros-humble-gazebo-ros \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-joint-state-publisher \
    ros-humble-robot-localization \
    ros-humble-plotjuggler-ros \
    ros-humble-robot-state-publisher \
    ros-humble-ros2bag \
    ros-humble-rosbag2-storage-default-plugins \
    ros-humble-rqt-tf-tree \
    ros-humble-rmw-fastrtps-cpp \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-slam-toolbox \
    ros-humble-turtlebot3 \
    ros-humble-turtlebot3-msgs \
    ros-humble-twist-mux \
    ros-humble-usb-cam \
    ros-humble-xacro \
    ruby-dev \
    rviz \
    tmux \
    wget \
    xorg-dev \
    zsh
    
RUN pip3 install setuptools==58.2.0

RUN wget https://github.com/openrr/urdf-viz/releases/download/v0.38.2/urdf-viz-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xvzf urdf-viz-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/urdf-viz && \
    rm -f urdf-viz-x86_64-unknown-linux-gnu.tar.gz

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN gem install tmuxinator && \
    wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y vim

RUN apt-get update && apt-get install -y \
    python3-tk \
    dvipng \
    texlive-latex-extra\
    texlive-fonts-recommended\
    cm-super\
    libgl1-mesa-glx\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
# bash
RUN echo "TERM=xterm-256color" >> ~/.bashrc
RUN echo "# COLOR Text" >> ~/.bashrc
RUN echo "PS1='\[\033[01;33m\]\u\[\033[01;33m\]@\[\033[01;33m\]\h\[\033[01;34m\]:\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\$ '" >> ~/.bashrc
RUN echo "CLICOLOR=1" >> ~/.bashrc
RUN echo "LSCOLORS=GxFxCxDxBxegedabagaced" >> ~/.bashrc
RUN echo "# ROS" >> ~/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo 'alias gb="vim ~/.bashrc"' >> ~/.bashrc
RUN echo 'alias gi="source ~/.bashrc"' >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc 


## Acados Installation
RUN echo "Building acados"
RUN cd ${HOME} && git clone https://github.com/acados/acados.git
RUN cd ${HOME}/acados  && git checkout 37e17d31890ab54e5a855f1fe787fbf2f5d43bdb
RUN cd ${HOME}/acados && git submodule init
RUN cd ${HOME}/acados && git submodule update --recursive
RUN cd ${HOME}/acados && mkdir -p build
RUN cd ${HOME}/acados/build && cmake -DACADOS_WITH_QPOASES=ON -DACADOS_INSTALL_DIR="${HOME}/acados" ..
RUN cd ${HOME}/acados/build && make install -j4
RUN cd ${HOME}/acados && make shared_library
RUN cd ${HOME}/acados && make examples_c
RUN echo "Building acados  completed"


RUN echo ""
RUN echo "install pyyaml"
RUN pip install pyyaml 
RUN echo ""
RUN echo "install pynput"
RUN pip install pynput

RUN echo "Building acados template"
RUN pip install -e ${HOME}/acados/interfaces/acados_template

RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/acados/lib' >> ~/.bashrc
RUN echo "export ACADOS_SOURCE_DIR=${HOME}/acados" >> ~/.bashrc
RUN echo "building tera_renderer"
RUN cd ${HOME} && git clone https://github.com/acados/tera_renderer
RUN cd ${HOME} && cd tera_renderer
RUN cd ${HOME} && cd tera_renderer && curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN echo "source ${HOME}/.cargo/env" >> ~/.bashrc
RUN cd  ${HOME}/tera_renderer && \
    /bin/bash -c "source ${HOME}/.cargo/env && cargo build --verbose --release"
RUN cd  ${HOME}/tera_renderer && \
    /bin/bash -c "cp target/release/t_renderer ${HOME}/acados/bin/t_renderer"

# Installing Casadi in python
RUN echo "install casadi"
#pip3 uninstall casadi
RUN pip install casadi

RUN echo "Cloning Invert Pendulum Repo"
RUN sudo apt update
RUN sudo apt upgrade

# Intall libraries for Mujoco
RUN sudo apt-get install libglfw3
RUN sudo apt-get install libglfw3-dev

RUN echo "export WS=/home/ws" >> ~/.bashrc

RUN echo "Install mujoco"
RUN pip install mujoco

RUN echo "Install osqp"
RUN pip install osqp
#USER $USERNAME
#RUN cd  ${HOME}/tera_renderer && \
    #/bin/bash -c "cp target/release/t_renderer ${HOME}/acados/bin/t_renderer"
#RUN cd ${WS}/src
#git clone https://github.com/lfrecalde1/Pendulum_cart.git