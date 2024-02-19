package someusecase

import (
	"fmt"
	"github.com/skyhawk-security/[[[ .ServiceName ]]]/domain/entity"
)

func New[[[ .ServiceNameUpper ]]]UseCaseImplementation() *[[[ .ServiceNameUpper ]]]UseCaseImplementation {
	return &[[[ .ServiceNameUpper ]]]UseCaseImplementation{}
}

func (us *[[[ .ServiceNameUpper ]]]UseCaseImplementation) SayHello(user entity.Person) string {
	return fmt.Sprintf("Hello %s!", user.Name)
}
