FROM docker:18.09 AS dind

FROM codercom/code-server:1.939

LABEL version="1.939"
LABEL maintainer="Hugo Slabbert <hugo@slabnet.com>"

RUN sudo apt update && sudo apt install -y \
  curl python3 python3-setuptools vim tmux wget\
  build-essential libffi-dev python3-dev

COPY --from=dind /usr/local/bin/modprobe /usr/local/bin/modprobe
RUN wget -O docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-18.09.5.tgz\
  && sudo tar --extract \
    --file docker.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    ; \
    rm docker.tgz

EXPOSE 8443
ENTRYPOINT ["dumb-init", "code-server"]