# Define custom function directory
ARG FUNCTION_DIR="/app"

FROM node:14-buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies
# RUN apt-get install git-all
RUN apt-get update && \
    apt-get install -y \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev \
    git-all

RUN apt-get install git-all

RUN apt-get update

# Copy function code
RUN mkdir -p ${FUNCTION_DIR}
COPY package.json next.config.js package-lock.json ${FUNCTION_DIR}/

WORKDIR ${FUNCTION_DIR}

# If the dependency is not in package.json uncomment the following line
RUN npm install aws-lambda-ric
RUN npm install

COPY src ${FUNCTION_DIR}

COPY index.js next.config.js ${FUNCTION_DIR}/

RUN mkdir -p ${FUNCTION_DIR}/.next
# Grab a fresh slim copy of the image to reduce the final size
# FROM node:14-buster-slim

# # Include global arg in this stage of the build
# ARG FUNCTION_DIR

# # Set working directory to function root directory
# WORKDIR ${FUNCTION_DIR}

# # Copy in the built dependencies
# COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

RUN chown -R node:node ${FUNCTION_DIR}
USER node

ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]
CMD ["index.handler"]
