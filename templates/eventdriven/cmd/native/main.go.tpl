package main

import (
	"github.com/skyhawk-security/{{ .ServiceName }}/usecase/myusecase"
)

func main() {
	_ = myusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	// invoke a use case method to actually do something
}
