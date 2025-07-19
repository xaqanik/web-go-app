# Containerize the go application that we have created
# This is the Dockerfile that we will use to build the image
# and run the container

# Start with a base image
FROM golang:1.22.5 as builder

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
FROM gcr.io/distroless/static-debian11

# Set the working directory
WORKDIR /

# Create a non-root user
USER nonroot:nonroot

# Copy the binary from the previous stage
COPY --from=builder /app/main .

# Copy the static files from the previous stage
COPY --from=builder /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["/main"]