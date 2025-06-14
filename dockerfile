FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
EXPOSE 22
CMD ["bash"]