package handler

import (
	"github.com/go-chi/chi/v5"
	chiMiddleware "github.com/go-chi/chi/v5/middleware"
    middleware "github.com/deepmap/oapi-codegen/pkg/chi-middleware"
	"github.com/skyhawk-security/{{ .ServiceName }}/api"
	"github.com/skyhawk-security/{{ .ServiceName }}/usecase/someusecase"
	"net/http"
)

type ChiHandler struct {
	Usecase someusecase.{{ .ServiceNameUpper }}UseCase
}

func NewChiHandler(usecase someusecase.{{ .ServiceNameUpper }}UseCase) (http.Handler, error) {
    handlerFunctions := &ChiHandler{
		Usecase: usecase,
	}

	swaggerSpec, err := api.GetSwagger()
	if err != nil {
		return nil, err
	}

	r := chi.NewRouter()
	r.Use(chiMiddleware.Logger)
	r.Use(chiMiddleware.RequestID)
	r.Use(chiMiddleware.RealIP)
	r.Use(chiMiddleware.Recoverer)
	r.Use(middleware.OapiRequestValidator(swaggerSpec))

    // NOTE: Hover over handlerFunctions and implement the missing methods
	strictHandler := api.NewStrictHandler(handlerFunctions, nil)

	// IMPORTANT: make sure that you have successfully generated the server through the OpenAPI generator. otherwise, it won't work.
	return api.HandlerFromMux(strictHandler, r), nil
}
