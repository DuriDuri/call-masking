FROM golang:alpine as builder

ENV GOPRIVATE=github.com/DuriDuri

# Add Maintainer info
LABEL maintainer="Duri Abdurahman Duri <duri@parsleyhealth.com>"

# Install git.
RUN apk update && apk add --no-cache git
RUN apk add --no-cache openssh-client

# Set the current working directory inside the container
WORKDIR /app

ARG SSH_PRIVATE_KEY

RUN mkdir -p ~/.ssh && umask 0077 && echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa \
	&& git config --global url."git@github.com:".insteadOf https://github.com/ \
	&& ssh-keyscan github.com >> ~/.ssh/known_hosts

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and the go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the working Directory inside the container
COPY . .

RUN CGO_ENABLED=0 go test -v ./...

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o call-masking cmd/api/main.go

# Start a new stage from scratch
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage. Observe we also copied the .env file
COPY --from=builder /app/call-masking .
COPY --from=builder /app/config.yml .

# Expose port 8080 to the outside world
EXPOSE 8080

#Command to run the executable
ENTRYPOINT [ "./call-masking" ]
