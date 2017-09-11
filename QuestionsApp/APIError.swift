import Foundation

class APIError: Error {
    private(set) var code: Int?
    private(set) var message: String?
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
    
    convenience init(json: NSDictionary) {
        let message = json[Key.JSON.APIError.message] as? String ?? ""
        let code = json[Key.JSON.APIError.code] as? Int ?? 0
        
        self.init(code: code, message: message)
    }
    
    func isServiceUnavailable() -> Bool {
        return code == 503
    }
    
    func getErrorMessage() -> String {
        if isServiceUnavailable() {
           // return Key.ErrorMessage.serviceUnavailable.localized
        }
        
        return "UnknownError"
    }
}
