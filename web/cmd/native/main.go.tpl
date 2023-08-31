package main

import (
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/api/chi/handler"
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/usecase/someusecase"
	"net/http"
)

func main() {
	// create an usecase implementation. we only need to pass a repository object.
	usecaseImplementation := someusecase.New{{ .ServiceNameUpper }}UseCaseImplementation()

	server := handler.NewChiHandler(usecaseImplementation)

	http.ListenAndServe(":8000", server)
}
