FROM docker:18.09 AS dind

FROM codercom/code-server:3.7.4

LABEL version="3.7.4.1"
LABEL maintainer="Hugo Slabbert <hugo@slabnet.com>"

RUN sudo apt update && sudo apt install -y \
  curl python3 python3-setuptools vim tmux wget\
  build-essential libffi-dev python3-dev\
  && sudo rm -rf /var/lib/apt/lists/*

RUN mkdir ~/build && cd ~/build\
  && git clone https://github.com/udhos/update-golang.git\
  && cd update-golang\
  && wget -qO hash.txt https://raw.githubusercontent.com/udhos/update-golang/master/update-golang.sh.sha256\
  && sha256sum -c hash.txt\
  && sudo RELEASE=1.15.6 ./update-golang.sh\
  && sudo rm /usr/local/go*.tar.gz\
  && cd\
  && rm -Rf build

RUN mkdir ~/build && cd ~/build\
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.8/bin/linux/amd64/kubectl\
  && chmod +x ./kubectl\
  && sudo mv ./kubectl /usr/local/bin/kubectl\
  && cd\
  && rm -Rf ~/build

RUN mkdir ~/build && cd ~/build\
  && git clone https://github.com/ahmetb/kubectx\
  && sudo mv kubectx /opt/kubectx\
  && sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx\
  && sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens\
  && cd\
  && rm -Rf ~/build

COPY --from=dind /usr/local/bin/modprobe /usr/local/bin/modprobe
RUN wget -O docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.09.5.tgz\
  && sudo tar --extract \
    --file docker.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    ; \
    rm docker.tgz; \
    sudo addgroup --gid 999 docker; \
    sudo usermod -a -G docker coder; \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py; \
    sudo -H python3 get-pip.py; \
    sudo -u coder pip install virtualenvwrapper --user

EXPOSE 8443
ENTRYPOINT ["dumb-init", "code-server"]
