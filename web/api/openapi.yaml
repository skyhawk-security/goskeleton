openapi: "3.0.0"
info:
    title: "Some Service"
    description: |
        Specification for some service.
    version: "0.0.1"
    contact:
        name: "Reshef Sharvit"
        email: "reshefsharvit21@gmail.com"
paths:
    /hello:
        summary: "Say hello"
        post:
            operationId: "hello"
            summary: "hello"
            requestBody:
                description: "Person details"
                required: true
                content:
                    application/json:
                        schema:
                            $ref: "#/components/schemas/Person"
            responses:
                '200':
                    description: |
                        Login successful
                    content:
                        application/json:
                            schema:
                                $ref: "#/components/schemas/HelloOutput"
                'default':
                    description: |
                        Operation failed.
                    content:
                        application/json:
                            schema:
                                $ref: "#/components/schemas/ErrorOutput"
components:
    schemas:
        Person:
            type: "object"
            required: ["name"]
            properties:
                name:
                    type: string
        HelloOutput:
            type: "object"
            required: [ "message" ]
            properties:
                message:
                    type: string
        ErrorOutput:
            type: "object"
            required: ["message", "status_code"]
            properties:
                message:
                     type: "string"            
                status_code:
                     type: "integer" 
