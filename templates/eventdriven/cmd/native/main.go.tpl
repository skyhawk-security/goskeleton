package main

import (
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/usecase/myusecase"
)

func main() {
	_ = myusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	// invoke a use case method to actually do something
}
