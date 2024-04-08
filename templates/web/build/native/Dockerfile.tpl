# Stage 1: Build the Go application
FROM golang:1.21 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY .. .
RUN CGO_ENABLED=0 GOOS=linux go build -o cmd/native/main.go .

# Stage 2: Create a minimal runtime image
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/app .

ENTRYPOINT ["./app"]