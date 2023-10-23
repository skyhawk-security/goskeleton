package main

import (
	"github.com/skyhawk-security/{{ .ServiceName }}/api/chi/handler"
	"github.com/skyhawk-security/{{ .ServiceName }}/usecase/someusecase"
	"net/http"
)

func main() {
	// create an usecase implementation. we only need to pass a repository object.
	usecaseImplementation := someusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	serverHandler, err := handler.NewChiHandler(usecaseImplementation)
	if err != nil {
	    panic("could not initialize handler with error: " + err.Error())
	}

	err = http.ListenAndServe(":8000", serverHandler)
    if err != nil {
    	panic(err)
   	}
}
