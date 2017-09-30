FROM rahuldivgan/infrabase

MAINTAINER Rahul Divgan <rahuldivgan@gmail.com>

ADD terraform/* /
#ADD entrypoint.py /entrypoint.py

RUN terraform init

ENTRYPOINT ["terraform"]
CMD ["plan"]
