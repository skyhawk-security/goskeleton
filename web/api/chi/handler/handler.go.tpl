package handler

import (
	"encoding/json"
	server "github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/api"
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/domain/entity"
	"github.com/skyhawk-security/golang-example-repository/services/{{ .ServiceName }}/usecase/someusecase"
	"net/http"
)

type ChiHandler struct {
	Usecase someusecase.{{ .ServiceNameUpper }}UseCase
}

func (h *ChiHandler) Hello(w http.ResponseWriter, r *http.Request) {
	var input server.Person

	// Decode JSON from the request body
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Close the request body after reading
	defer r.Body.Close()

	message := h.Usecase.SayHello(entity.Person(input))

	jsonData, err := json.Marshal(server.HelloOutput{
		Message: message,
	})

	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Write(jsonData)

}

func NewChiHandler(usecase someusecase.{{ .ServiceNameUpper }}UseCase) http.Handler {
	h := &ChiHandler{
		Usecase: usecase,
	}

	// IMPORTANT: make sure that you have successfully generated the server through the OpenAPI generator. otherwise, it won't work.
	return server.Handler(h)
}
