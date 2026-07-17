//
//  APIServiceProtocol.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIEndPoint:String {
    case getUserData = "users"
}
enum APIError: LocalizedError {
    case invalidURL
    case network
    case decodingError
    case sessionExpired
    case forbidden
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .network:
            return "Network error occurred."
        case .decodingError:
            return "Failed to parse response."
        case .sessionExpired:
            return "Session expired."
        case .forbidden:
            return "You don’t have permission."
        case .serverError(let message):
            return message
        }
    }
}


var BaseUrl = "https://jsonplaceholder.typicode.com/"
 protocol APIServiceProtocol {
  //  func getData(completion: @escaping (Result<Data, Error>) -> Void)
     func request<T: Decodable>(endPoint:APIEndPoint, method:HttpMethod, param:[String:Any]?,accessToken: String?, responseType: T.Type) async throws -> T
    }


/*import Foundation
 
 enum DataError: Error {
     case invalidResponse
     case invalidURL
     case invalidData
     case network
     case decodingError
     case sessionExpired
     case message(String)
 }
 protocol MediaUploadingProgressDelegate{
     func uploadProgress(progress: Float)
     func uploadStatus(id:String,success:Bool)
 }

 extension DataError: CustomStringConvertible {
     public var description: String {
         switch self {
         case .invalidResponse:
             return "An unexpected error occurred."
         case .invalidURL:
             return "The specified url could not be found."
         case .invalidData :
             return "An unexpected error occurred."
         case .network:
             return "Something  went  wrong!"
         case .decodingError:
             return "Data parsing error!"
         case .sessionExpired:
             return "Login session has expired!"
         case .message(let error):
             return error
         }
     }
 }
 typealias ResultHandler<T> = (Result<T, DataError>) -> Void?
 typealias ResultHandlerv2 = (Result<[String: Any], DataError>) -> Void?


 final class HttpRequestManager {
     static let httpRequest = HttpRequestManager()
     private let networkHandler: NetworkHandler
     private let networkHandlerForUploadVideo: NetworkHandlerForUploadVideo
     private let responseHandler: ResponseHandler
     private let apiVesion = "9.0"
     var delegate:MediaUploadingProgressDelegate?
     private init(networkHandler: NetworkHandler = NetworkHandler(),
          responseHandler: ResponseHandler = ResponseHandler()) {
         self.networkHandler = networkHandler
         self.responseHandler = responseHandler
         self.networkHandlerForUploadVideo = NetworkHandlerForUploadVideo()
     }
   //  private init(){}
     
     func postData<T:Decodable>(url: String,param:[String:Any] ,userTokenRequire: Bool, resultType:T.Type, completionHandler:@escaping ResultHandler<T?>) {
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.beta.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qa.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiion.rawValue + url)
         }
         
       //  = baseUrl == .qa ? (BaseURL.qa.rawValue + url) : (BaseURL.beta.rawValue + url)
         guard let url = URL(string: urlStr) else  {
             completionHandler(.failure(.invalidURL))
             return
         }
         var request = URLRequest(url:  url)
         request.httpMethod = "post"
         request.addValue("application/json", forHTTPHeaderField: "content-type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
         request.httpBody = try? JSONSerialization.data(withJSONObject: param)
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
         }
         
         Logger.logRequestParams(key: "request", url:urlStr, header:request.allHTTPHeaderFields ?? [:], value: param )
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
     }
     
    
    
     //https://dummyjson.com/products
     func getData<T: Decodable>(url: String,param:[String:Any]? ,userTokenRequire: Bool, resultType:T.Type, completionHandler: @escaping ResultHandler<T>){
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.beta.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qa.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiion.rawValue + url)
         }
       //  let  urlStr = baseUrl == .qa ? (BaseURL.qa.rawValue + url) : (BaseURL.beta.rawValue + url)
       //  BaseUrl.sBaseApiUrl = "sds"
         var formattedUrlString = (urlStr)
         if param != nil{
             if let urlParameters = param {
                 if !(urlParameters.isEmpty) {
                     formattedUrlString.append("?")
                     var array:[String] = []
                     let _ = urlParameters.map { (key, value) -> Bool in
                         let str = key + "=" +  String(describing: value)
                         array.append(str)
                         return true
                     }
                     formattedUrlString.append(array.joined(separator: "&"))
                 }
             }
         }
         
        // print("url...",formattedUrlString)
         var request = URLRequest(url: URL(string:formattedUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")!)
         request.httpMethod = "get"
         request.addValue("application/json", forHTTPHeaderField: "content-type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
             print("baearer Bearer \(accessToken)" )
         }
         Logger.logRequestParams(key: "request", url:formattedUrlString, header:request.allHTTPHeaderFields ?? [:], value: [:])
         
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
  
 //        URLSession.shared.dataTask(with: request) { data, response, error in
 //            if(error == nil && data != nil) {
 //                do {
 //                    let res =  try JSONDecoder().decode(resultType.self, from: data!)
 //                    let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:AnyObject]
 //                    debugPrint(json ?? ["":""])
 //                    completionHandler(.success(res))
 //                } catch (let error){
 //                    print(error.localizedDescription)
 //                }
 //            }else{
 //                completionHandler(.failure(error!))
 //            }
 //        }.resume()
     }
     
     func getDataV2<T: Decodable>(url: String,param:[String:Any]? ,userToken:String = "", resultType:T.Type, completionHandler: @escaping ResultHandler<T>){
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.beta.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qa.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiion.rawValue + url)
         }
       //  let  urlStr = baseUrl == .qa ? (BaseURL.qa.rawValue + url) : (BaseURL.beta.rawValue + url)
       //  BaseUrl.sBaseApiUrl = "sds"
         var formattedUrlString = (urlStr)
         if param != nil{
             if let urlParameters = param {
                 if !(urlParameters.isEmpty) {
                     formattedUrlString.append("?")
                     var array:[String] = []
                     let _ = urlParameters.map { (key, value) -> Bool in
                         let str = key + "=" +  String(describing: value)
                         array.append(str)
                         return true
                     }
                     formattedUrlString.append(array.joined(separator: "&"))
                 }
             }
         }
         
        // print("url...",formattedUrlString)
         var request = URLRequest(url: URL(string:formattedUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")!)
         request.httpMethod = "get"
         request.addValue("application/json", forHTTPHeaderField: "content-type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
         if userToken != ""{
             request.allHTTPHeaderFields = ["Authorization": "\(userToken)"]
             print("baearer Bearer \(userToken)" )
         }
           
       
         Logger.logRequestParams(key: "request", url:formattedUrlString, header:request.allHTTPHeaderFields ?? [:], value: [:])
         
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
     }
     func deleteData<T: Decodable>(url: String,param:[String:Any]? ,userTokenRequire: Bool, resultType:T.Type, completionHandler: @escaping ResultHandler<T>){
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.beta.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qa.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiion.rawValue + url)
         }
        // let  urlStr = baseUrl == .qa ? (BaseURL.qa.rawValue + url) : (BaseURL.beta.rawValue + url)
       //  BaseUrl.sBaseApiUrl = "sds"
         var formattedUrlString = (urlStr)
         if param != nil{
             if let urlParameters = param {
                 if !(urlParameters.isEmpty) {
                     formattedUrlString.append("?")
                     var array:[String] = []
                     let _ = urlParameters.map { (key, value) -> Bool in
                         let str = key + "=" +  String(describing: value)
                         array.append(str)
                         return true
                     }
                     formattedUrlString.append(array.joined(separator: "&"))
                 }
             }
         }
         //print("url...",formattedUrlString)
         var request = URLRequest(url: URL(string:formattedUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")!)
         request.httpMethod = "delete"
         request.addValue("application/json", forHTTPHeaderField: "content-type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
             print("baearer Bearer \(accessToken)" )
         }
         Logger.logRequestParams(key: "request", url:formattedUrlString, header:request.allHTTPHeaderFields ?? [:], value: [:])
         
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
     }
     
     
     func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
     }
     func postMediaData<T:Decodable>(url: String,param:[String:Any], media: Media? ,userTokenRequire: Bool, resultType:T.Type, completionHandler:@escaping ResultHandler<T?>) {
         guard let mediaVideo = media else { return }
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.betaMutliPart.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qaMutliPart.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiionMutliPart.rawValue + url)
         }
       //  let  urlStr = baseUrl == .qa ? (BaseURL.qaMutliPart.rawValue + url) : (BaseURL.betaMutliPart.rawValue + url)
         guard let url = URL(string: urlStr) else  {
             completionHandler(.failure(.invalidURL))
             return
         }
         var request = URLRequest(url:  url)
         request.httpMethod = "post"
         let boundary = generateBoundary()
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
        // request.addValue("application/json", forHTTPHeaderField: "content-type")
         let dataBody = createDataBody(withParameters: param, media: [mediaVideo], boundary: boundary)
         request.httpBody = dataBody
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
         }
         
         Logger.logRequestParams(key: "request", url:urlStr, header:request.allHTTPHeaderFields ?? [:], value: param )
         networkHandlerForUploadVideo.uploadProgress = { (progress: Float) -> () in
             self.delegate?.uploadProgress(progress: progress)
         }
         networkHandlerForUploadVideo.updateStatus = {(id:String, success:Bool) -> () in
             self.delegate?.uploadStatus(id: id, success: success)
         }
         var identifier = "\((param["VideoID"] as?  Int) ?? 0)\((param["AssessmentID"] as?  Int) ?? 0)"
         print("identtifier:::\(identifier)")
         // Network Request - URL TO DATA
         networkHandlerForUploadVideo.requestDataAPI(url: request, identifier:identifier) { result  in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }

     
     }
     
     func postMediaDataV2<T:Decodable>(url: String,param:[String:Any], media: Media? ,userTokenRequire: Bool, resultType:T.Type, completionHandler:@escaping ResultHandler<T?>) {
        // guard let mediaVideo = media else { return }
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.betaMutliPart.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qaMutliPart.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiionMutliPart.rawValue + url)
         }
       //  let  urlStr = baseUrl == .qa ? (BaseURL.qaMutliPart.rawValue + url) : (BaseURL.betaMutliPart.rawValue + url)
         guard let url = URL(string: urlStr) else  {
             completionHandler(.failure(.invalidURL))
             return
         }
         var request = URLRequest(url:  url)
         request.httpMethod = "post"
         let boundary = generateBoundary()
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
        // request.addValue("application/json", forHTTPHeaderField: "content-type")
         if let mediaVideo = media {
             let dataBody = createDataBody(withParameters: param, media: [mediaVideo], boundary: boundary)
             request.httpBody = dataBody
         } else {
             let dataBody = createDataBody(withParameters: param, media: nil, boundary: boundary)
             request.httpBody = dataBody
         }
         
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
         }
         
         Logger.logRequestParams(key: "request", url:urlStr, header:request.allHTTPHeaderFields ?? [:], value: param )
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result  in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
     }
     
     func createDataBody(withParameters params: [String:Any]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
           for (key, value) in parameters {
              body.append("--\(boundary + lineBreak)")
              body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
             
               body.append("\(String(describing: value) + lineBreak)")
           }
        }
        if let media = media {
           for video in media {
              body.append("--\(boundary + lineBreak)")
              body.append("Content-Disposition: form-data; name=\"\(video.key)\"; filename=\"\(video.filename)\"\(lineBreak)")
              body.append("Content-Type: \(video.mimeType + lineBreak + lineBreak)")
              body.append(video.data)
              body.append(lineBreak)
           }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
     }
 }



 class NetworkHandler {
     func requestDataAPI(
         url: URLRequest,
         completionHandler: @escaping (Result<Data, DataError>) -> Void
     ) {
         let session = URLSession.shared.dataTask(with: url) { data, response, error in
             if error != nil {
                 completionHandler(.failure(.message(error!.localizedDescription)))
                 return
             }
             guard let response = response as? HTTPURLResponse else {
                 completionHandler(.failure(.network))
                 return
             }
             switch  response.statusCode {
             case 200 ... 299 :
                     guard let data else {
                         completionHandler(.failure(.invalidData))
                         return
                     }
                     completionHandler(.success(data))
             case 401 :
                 debugPrint("Session has expired!")
                 completionHandler(.failure(.sessionExpired))
           case 403 :
                 debugPrint("No access permission")
                 guard let data else {
                     completionHandler(.failure(.invalidData))
                     return
                 }
                 completionHandler(.success(data))
             default:
                 debugPrint("Error: \(error?.localizedDescription ?? "")")
                 completionHandler(.failure(.network))
             }
         }
         session.resume()
     }
 }

 class NetworkHandlerForUploadVideo: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
     private var totalBytesSent: Int64 = 0
        private var totalBytesExpectedToSend: Int64 = 0
     var uploadProgress:((_ progress: Float)->())?
     var updateStatus:((_ id: String, _ success:Bool)->())?
     func requestDataAPI(
         url: URLRequest,identifier:String = "",
         completionHandler: @escaping (Result<Data, DataError>) -> Void
     ) {
         let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
         let task = session.dataTask(with: url)
 //      let task =  session.dataTask(with: url) { data, response, error in
 //            if error != nil {
 //                completionHandler(.failure(.message(error!.localizedDescription)))
 //                return
 //            }
 //            guard let response = response as? HTTPURLResponse else {
 //                completionHandler(.failure(.network))
 //                return
 //            }
 //            switch  response.statusCode {
 //            case 200 ... 299 :
 //                    guard let data else {
 //                        completionHandler(.failure(.invalidData))
 //                        return
 //                    }
 //                completionHandler(.success(data))
 //            case 401 :
 //                debugPrint("Session has expired!")
 //                completionHandler(.failure(.sessionExpired))
 //            default:
 //                debugPrint("Error: \(error?.localizedDescription ?? "")")
 //                completionHandler(.failure(.network))
 //            }
 //        }
            task.taskDescription = identifier
            task.resume()
         
     }
     
     func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
         
         if let error = error {
             self.updateStatus?(task.taskDescription ?? "",false)
             print("Upload task \(task.taskDescription ?? "") failed with error: \(error)")
         } else {
             print("Upload task \(task.taskDescription ?? "") completed successfully.")
         }
     }
     
     func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
         guard let response = response as? HTTPURLResponse else {
             self.updateStatus?(dataTask.taskDescription ?? "",false)
                    return
                }
                switch  response.statusCode {
                case 200 ... 299 :
                    self.updateStatus?(dataTask.taskDescription ?? "",true)
                case 401 :
                    debugPrint("Session has expired!")
                    self.updateStatus?(dataTask.taskDescription ?? "",false)
                default:
                    self.updateStatus?(dataTask.taskDescription ?? "",false)
                }
          
         print("uploaded file \(dataTask.taskDescription ?? "")")
     }
     func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
             self.totalBytesSent = totalBytesSent
             self.totalBytesExpectedToSend = totalBytesExpectedToSend
             reportProgress()
         }
     private func reportProgress() {
           let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
         DispatchQueue.main.async { [self] in
               // Update your UI with the progress value, e.g., update a progress bar
             uploadProgress?(progress)
               print("Progress: \(progress)")
               
           }
       }

 }
 class ResponseHandler {
     
     func parseResonseDecode<T: Decodable>(
         data: Data,
         resultType: T.Type,
         completionHandler: ResultHandler<T>
     ) {
        
         do {
             let userResponse = try JSONDecoder().decode(resultType, from: data)
             Logger.logResponseParams(key: "Response", value: data.convertDataToDictionary()!)
             completionHandler(.success(userResponse))
         }catch  let error {
             debugPrint(error.localizedDescription)
             completionHandler(.failure(.decodingError))
         }
     }
     
 }


 class ResponseHandlerV2 {
     func parseResonseDecode(
         data: Data,
         resultType: [String:Any].Type,
         completionHandler: ResultHandlerv2
     ) {
         Logger.logResponseParams(key: "Response", value: data.convertDataToDictionary()!)
         do {
                 if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]{
                     
 //                    var statusDict: [String: Int] = [:]
 //                    for item in dataArray {
 //                        if let status = item["status"] as? String,
 //                           let count = item["count"] as? Int {
 //                            statusDict[status] = count
 //                        }
 //                    }
                     completionHandler(.success(json))
                     print("Parsed Dictionary: \(json)")
                     // Example Output: ["Completed": 1, "Pending": 6]

                 } else {
                     //completionHandler(.failure("Invalid JSON structure"))
                     completionHandler(.failure(.invalidData))
                     print("Invalid JSON structure")
                 }
             } catch let error {
                 completionHandler(.failure(.decodingError))
                 print("JSON decoding error: \(error)")
             }
       
     }
     
 }


 final class HttpRequestManagerV2 {
     static let httpRequest = HttpRequestManagerV2()
     private let networkHandler: NetworkHandler
     private let networkHandlerForUploadVideo: NetworkHandlerForUploadVideo
     private let responseHandler: ResponseHandlerV2
     private let apiVesion = "9.0"
     var delegate:MediaUploadingProgressDelegate?
     private init(networkHandler: NetworkHandler = NetworkHandler(),
                  responseHandler: ResponseHandlerV2 = ResponseHandlerV2()) {
         self.networkHandler = networkHandler
         self.responseHandler = responseHandler
         self.networkHandlerForUploadVideo = NetworkHandlerForUploadVideo()
     }
     
     func postData(url: String,param:[String:Any] ,userTokenRequire: Bool, resultType:[String:Any].Type, completionHandler:@escaping ResultHandlerv2) {
         var  urlStr = ""
         switch baseUrl {
         case .beta:
             urlStr = (BaseURL.beta.rawValue + url)
         case .qa:
             urlStr = (BaseURL.qa.rawValue + url)
         case .production:
             urlStr = (BaseURL.productiion.rawValue + url)
         }
         
         //  = baseUrl == .qa ? (BaseURL.qa.rawValue + url) : (BaseURL.beta.rawValue + url)
         guard let url = URL(string: urlStr) else  {
             completionHandler(.failure(.invalidURL))
             return
         }
         var request = URLRequest(url:  url)
         request.httpMethod = "post"
         request.addValue("application/json", forHTTPHeaderField: "content-type")
         request.addValue(apiVesion, forHTTPHeaderField: "x-api-version")
         request.httpBody = try? JSONSerialization.data(withJSONObject: param)
         if userTokenRequire{
             let accessToken:String = Organizer.shared.token ?? ""
             request.allHTTPHeaderFields = ["Authorization": "\(accessToken)"]
         }
         
         Logger.logRequestParams(key: "request", url:urlStr, header:request.allHTTPHeaderFields ?? [:], value: param )
         // Network Request - URL TO DATA
         networkHandler.requestDataAPI(url: request) { result in
             switch result {
             case .success(let data):
                 // Json parsing - Decoder - DATA TO MODEL
                 self.responseHandler.parseResonseDecode(
                     data: data,
                     resultType: resultType) { response in
                         switch response {
                         case .success(let mainResponse):
                             completionHandler(.success(mainResponse)) // Final
                         case .failure(let error):
                             completionHandler(.failure(error))
                         }
                     }
             case .failure(let error):
                 completionHandler(.failure(error))
             }
         }
     }
 }



*/
