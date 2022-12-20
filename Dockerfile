FROM node:18-alpine
WORKDIR /app

#copy config
COPY package*.json ./

RUN npm install

#copy src files
COPY server.js /app

CMD [ "npm", "start" ]


