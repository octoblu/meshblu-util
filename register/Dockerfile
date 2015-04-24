FROM octoblu/meshblu-util
MAINTAINER Octoblu <docker@octoblu.com>

RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
COPY run.sh /usr/src/app/

ENTRYPOINT ["./run.sh"]
