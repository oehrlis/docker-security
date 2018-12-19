FROM ubuntu:17.10
RUN apt-get update && apt-get install -y stress 
ENTRYPOINT ["stress"]
CMD ["-c", "2", "--timeout", "15"]
