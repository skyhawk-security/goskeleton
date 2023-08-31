package main

import (
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/api/chi/handler"
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/usecase/someusecase"
	"net/http"
)

func main() {
	// create an usecase implementation. we only need to pass a repository object.
	usecaseImplementation := someusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	serverHandler, err := handler.NewChiHandler(usecaseImplementation)
	if err != nil {
	    panic("could not initialize handler with error: " + err.Error())
	}

	http.ListenAndServe(":8000", serverHandler)
}
