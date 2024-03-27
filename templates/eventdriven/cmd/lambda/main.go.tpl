package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/skyhawk-security/[[[ .ServiceName ]]]/usecase/myusecase"
)

var userCaseImplementation *myusecase.[[[ .ServiceNameUpper ]]]UseCaseImplementation

// in lambdas, code outside the lambda context is preserved for subsequent runs. so we can use init() to initialize
// the dependencies and save valuable time and resources
func init() {
	userCaseImplementation = myusecase.New[[[ .ServiceNameUpper ]]]UseCaseImplementation()
}

// in lambdas, code outside the lambda context is preserved for subsequent runs. so we can use init() to initialize
// the dependencies and save valuable time and resources
func handler(ctx context.Context, event events.[[[ .EventSource ]]]Event) error {
	for _, record := range event.Records {
    	// unmarshal and/or implement your business logic here
    }

    return nil
}

func main() {
	lambda.Start(handler)
}
