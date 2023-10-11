package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/httpadapter"
	"github.com/skyhawk-security/{{ .ServiceName }}/api/chi/handler"
	"github.com/skyhawk-security/{{ .ServiceName }}/usecase/someusecase"
)

var httpLambda *httpadapter.HandlerAdapter

// in lambdas, code outside the lambda context is preserved for subsequent runs. so we can use init() to initialize
// the dependencies and save valuable time and resources
func init() {
	// create an usecase implementation. we only need to pass a repository object.
	usecaseImplementation := someusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	r, err := handler.NewChiHandler(usecaseImplementation)
	if err != nil {
	    panic("could not initialize handler with error: " + err.Error())
	}

	httpLambda = httpadapter.New(r)
}

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	ctx = context.WithValue(ctx, "RequestContext", req.RequestContext)
    return httpLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}
