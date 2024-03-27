FROM bash

RUN addgroup logger
RUN adduser -D -G logger logger

WORKDIR /log-generation
RUN chown -R logger:logger /log-generation

USER logger
COPY ./create-logs.sh .

CMD [ "bash", "./create-logs.sh" ]