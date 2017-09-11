struct Key {
    
    static let DeviceType = "iOS"
    
    struct URLs {
        static let baseAPIURL = "https://localhost:3443/api/v2.0/"
        static let localhost = "localhost"
    }
    
    struct Response {
        struct Code {
            static let ok = 200
        }
    }
    
    struct JSON {
        struct APIError {
            static let message = "message"
            static let code = "code"
        }
        
        struct Response {
            static let status =  "status"
        }
    }
    
    struct ErrorMessage {
        
    }
    
    struct Alert {
        static let errorTitle = "Error"
        static let buttonTitleOk = "Ok"
        static let buttonTitleCancel = "Cancel"
    }
    
    struct Message {
        static let recoverableException = "Recoverable exception. Attempt:"
    }
    
    
}
