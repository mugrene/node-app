FROM node:latest
WORKDIR /opt/node_app
COPY package.json ./
RUN apt update
RUN npm install
COPY . .
EXPOSE 4000
CMD [ "node", "index.js" ]
