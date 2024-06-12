#
# Create a populated git to work from
#
FROM node:20-alpine as git-build
RUN apk update \
    && apk add git

# Create a new repo
WORKDIR /home/git
RUN git config --global init.defaultBranch main \
    && git init repo

# Copy across the inital content
WORKDIR /home/git/repo
COPY repo/* .

# Make an initial commit
RUN git config --global user.email "demo@configuredthings.com" \
    && git config --global user.name "CT Demo" \
    && git add * \
    && git commit -a -m "baseline"

#
# Create the git server 
#
FROM node:20-alpine
RUN apk update \
    && apk add --no-cache tini git \
    && yarn global add git-http-server \
    && adduser -D -g git git

USER git
WORKDIR /home/git

#
# Create a bare repo
#
RUN git config --global init.defaultBranch main \
    && git init --bare repository.git

#
# Copy across the objects from the build image 
#
WORKDIR /home/git/repository.git
#RUN git symbolic-ref HEAD refs/heads/main
COPY --from=git-build /home/git/repo/.git/ ./

#
# Run the server on port 3000
#
ENTRYPOINT ["tini", "--", "git-http-server", "-p", "3000", "/home/git"]
