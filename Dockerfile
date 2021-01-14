# Imagem de contêiner que executa seu código
FROM ubuntu:latest
USER root
RUN apt update 
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install git sudo -y

# Copia o arquivo de código do repositório de ação para o caminho do sistema de arquivos `/` do contêiner
COPY src/ /intallers/
RUN chmod 777 /intallers/*
RUN chmod a+x /intallers/*
RUN bash /intallers/install.sh

# Arquivo de código a ser executado quando o contêiner do docker é iniciado (`entrypoint.sh`)
ENTRYPOINT ["/intallers/repo.sh"]