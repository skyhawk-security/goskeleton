package main

import (
	"github.com/skyhawk-security/[[[ .ServiceName ]]]/api/chi/handler"
	"github.com/skyhawk-security/[[[ .ServiceName ]]]/usecase/someusecase"
	"net/http"
)

func main() {
	// create an usecase implementation. we only need to pass a repository object.
	usecaseImplementation := someusecase.New[[[ .ServiceNameUpper ]]]UseCaseImplementation()

	serverHandler, err := handler.NewChiHandler(usecaseImplementation)
	if err != nil {
	    panic("could not initialize handler with error: " + err.Error())
	}

	server := &http.Server{
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       30 * time.Second,
		Addr:              ":8000",
		ReadHeaderTimeout: 30 * time.Second,
		Handler:           serverHandler,
	}

    err = server.ListenAndServe()
    if err != nil {
    	panic(err)
   	}
}
