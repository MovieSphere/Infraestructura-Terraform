FROM ubuntu:22.04
# Crear un usuario no-root
RUN useradd -m -s /bin/bash appuser
# Instalar paquetes como root
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
# Cambiar a usuario no-root
USER appuser
WORKDIR /home/appuser
EXPOSE 8080
CMD ["bash"]