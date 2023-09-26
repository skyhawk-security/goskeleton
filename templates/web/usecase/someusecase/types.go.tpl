package someusecase

import (
	"github.com/skyhawk-security/{{ .ServiceName }}/domain/entity"
)

// UseCase could be in a separate directory, as implemented here. but in case it's the only use case. it could also be placed directly in the usecase dir
type {{ .ServiceNameUpper }}UseCase interface {
	SayHello(person entity.Person) string
}

// this is the use case implementation.
// notice the lowercase repository. it means it's unexported and therefor cannot be accessed.
type {{ .ServiceNameUpper }}UseCaseImplementation struct {
}
