FROM alpine:latest

RUN apk add --no-cache samba samba-common-tools

EXPOSE 445

CMD ["smbd", "--foreground", "--no-process-group", "--debug-stdout"]