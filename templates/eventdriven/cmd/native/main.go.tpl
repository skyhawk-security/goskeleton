package main

import (
	"github.com/skyhawk-security/[[[ .ServiceName ]]]/usecase/myusecase"
)

func main() {
	_ = myusecase.New[[[ .ServiceNameUpper ]]]UseCaseImplementation()

    // native execution will poll an event source source as SQS/SNS
    // implement the polling mechanism and then invoke a use case method to actually do something
}
