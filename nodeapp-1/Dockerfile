# ========================================================
# Dockerfile to create docker image for node app
# Author: Venkatesh G
# Email: itsvenkatesh@gmail.com
# ========================================================
FROM node:16-alpine

# Set working directory for app
WORKDIR /usr/src/app

# copy package.json files to image
COPY package*.json ./

# Install node package manager in image
RUN npm install

# copy all files to image
COPY . .

# Expose port 8081 in the container
EXPOSE 8081

# command to start server
CMD [ "node", "server.js" ]
# ========================================================
# End of file
# ========================================================
