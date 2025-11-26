FROM node:alpine3.21

WORKDIR /app

COPY ./app.js .

COPY ./utilidades.js .

COPY ./package.json .

RUN npm install

EXPOSE 80

CMD [ "node", "app.js" ]