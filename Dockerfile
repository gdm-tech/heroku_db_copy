FROM node:alpine

RUN apk add --update curl bash postgresql wget
RUN curl https://cli-assets.heroku.com/install.sh | sh

COPY copy.sh /bin/copy.sh
RUN chmod +x /bin/copy.sh

RUN echo '0  *  *  *  *    /bin/copy.sh' > /etc/crontabs/root

CMD ['crond', '-l 2', '-f']
