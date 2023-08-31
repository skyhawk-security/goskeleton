package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/usecase/myusecase"
)

var userCaseImplementation *myusecase.{{ .ServiceNameUpper }}UseCaseImplementation

// in lambdas, code outside the lambda context is preserved for subsequent runs. so we can use init() to initialize
// the dependencies and save valuable time and resources
func init() {
	userCaseImplementation = myusecase.New{{ .ServiceName }}UseCaseImplementation()
}

// in lambdas, code outside the lambda context is preserved for subsequent runs. so we can use init() to initialize
// the dependencies and save valuable time and resources
// this is an SQS example but it could be of other event types
func handler(ctx context.Context, sqsEvent events.SQSEvent) error {
	return nil
}

func main() {
	lambda.Start(handler)
}
