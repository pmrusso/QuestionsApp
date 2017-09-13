import Foundation
import Alamofire

final class APIClient {
    
    fileprivate static let configName   = "APIConfig"
    
    fileprivate let baseAPIURL: String
    
    private let MAX_RETRIES = 5
    static let shared = APIClient()
    
    enum APIRequest {
        case getServerHealth(onSuccess: onSuccessFuncType, onError: onErrorFuncType)
        case listQuestions(limit: Int, offset: Int, filter: String, onSuccess: onSuccessFuncType, onError: onErrorFuncType)
    }
    
    private static var Manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            Key.URLs.localhost: .disableEvaluation
        ]
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
    fileprivate init() {
        baseAPIURL = APIClient.apiURLFromConfigFile()
    }
    
    func getServerHealth(onSuccess: @escaping onSuccessFuncType, onError: @escaping onErrorFuncType) {
        getServerHealth(onSuccess: onSuccess, onError: onError, attempt: 1)
    }
    
    func listQuestions(limit: Int, offset: Int, filter: String, onSuccess: @escaping onSuccessFuncType, onError: @escaping onErrorFuncType) {
        listQuestions(limit: limit, offset: offset, filter: filter, onSuccess: onSuccess, onError: onError, attempt: 1)
    }
    
    fileprivate func getServerHealth(onSuccess: @escaping onSuccessFuncType, onError: @escaping onErrorFuncType, attempt: Int) {
        let fullURL = baseAPIURL + "/health"
        apiRequest(fullURL: fullURL, method: .get, parameters: [:], onCompletion: onSuccess, onError: {[weak self] error in
            if (self?.isRecoverableException (error! as NSError) ?? false)  && attempt < (self?.MAX_RETRIES) ?? 0{
                self?.retryRequest(attempt: attempt, request: .getServerHealth(onSuccess: onSuccess, onError: onError))
                return
            }
            DispatchQueue.main.async {
                onError(error)
            }
        })
    }
    
    fileprivate func listQuestions(limit: Int, offset: Int, filter: String, onSuccess: @escaping onSuccessFuncType, onError: @escaping onErrorFuncType, attempt: Int) {
        let fullURL = baseAPIURL + "/questions?\(limit)&\(offset)&\(filter)"
        
        apiRequest(fullURL: fullURL, method: .get, parameters: [:], onCompletion: onSuccess, onError: {
            [weak self] error in
            if (self?.isRecoverableException (error! as NSError) ?? false)  && attempt < (self?.MAX_RETRIES) ?? 0{
                self?.retryRequest(attempt: attempt, request: .listQuestions(limit: limit, offset: offset, filter: filter, onSuccess: onSuccess, onError: onError))
                return
            }
            DispatchQueue.main.async {
                onError(error)
            }
        })
    }
    
    
    fileprivate func apiRequest(fullURL: String, method: HTTPMethod, parameters: [String:Any], onCompletion: @escaping onSuccessFuncType, onError: @escaping onErrorFuncType)
    {
        APIClient.Manager.request(fullURL, method: method, parameters: parameters).responseJSON {
            response in

            switch response.result {
            case .success(let jsonResponse):
                var json = NSDictionary()
                
                if let jsonTest = jsonResponse as? NSDictionary {
                    json = jsonTest
                }else if let jsonTest = jsonResponse as? NSArray {
                    json = [Key.JSON.Response.questions:jsonTest]
                }
                
                guard let errorCode = response.response?.statusCode,
                    errorCode == Key.Response.Code.ok else {
                        let apiErrorParameters = [Key.JSON.APIError.code : response.response?.statusCode,
                                                  Key.JSON.APIError.message : json[Key.JSON.Response.status]]
                        let error = APIError(json: apiErrorParameters as NSDictionary)
                        DispatchQueue.main.async {
                            onError(error)
                        }
                        return
                }
                
                onCompletion(json)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    fileprivate func retryRequest(attempt: Int, request: APIRequest) {
        let currentAttempt = attempt + 1
        print("\(Key.Message.recoverableException) \(currentAttempt)")
        
        switch request{
        default:
            return
        }
    }
    
    fileprivate func isRecoverableException(_ e: NSError) -> Bool {
        return (e._code == NSURLErrorCannotFindHost || e._code == NSURLErrorCannotConnectToHost || e._code == NSURLErrorTimedOut)
    }
}

extension APIClient {
    fileprivate static func apiURLFromConfigFile() -> String {
        var myDict: NSDictionary?
        
        if let path = Bundle.main.path(forResource: configName, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        } else {
            print("Error: Invalid path to \(configName) file.")
            return ""
        }
        
        guard let _ = myDict,
            let apiURL = myDict?["apiURL"] else{
                print("Error: APIURL not found.")
                return ""
        }
        return (apiURL as? String) ?? ""
    }
    
}
