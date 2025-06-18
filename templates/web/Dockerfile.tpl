# Stage 1: Build the Go application
FROM golang:1.23 AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -o /app/app cmd/native/main.go

# Stage 2: Create a minimal runtime image
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/app .

ENTRYPOINT ["./app"]