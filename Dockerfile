FROM python:3.10-alpine

ARG UID=1001

USER ${UID}

WORKDIR /app

COPY --chown=${UID} app/hello.html ./hello.html

EXPOSE 8000

CMD [ "python3", "-m", "http.server", "8000" ]
