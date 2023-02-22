//
//  NetworkLayer.swift
//  homework4.4
//
//  Created by Zhansuluu Kydyrova on 4/1/23.
//

import UIKit
import RxSwift
final class NetworkLayer {
    
    static let shared = NetworkLayer()
    private init() { }
    
    var baseURL = URL(string: "https://dummyjson.com/products")!
    
    func decodeOrderTypeData(_ json: String) -> [OrderTypeModel] {
        var orderTypeModelArray = [OrderTypeModel]()
        let orderTypeData = Data(json.utf8)
        let jsonDecoder = JSONDecoder()
        do { let orderTypeModelData = try jsonDecoder.decode([OrderTypeModel].self, from: orderTypeData)
            orderTypeModelArray = orderTypeModelData
        } catch {
            print(error.localizedDescription)
        }
        return orderTypeModelArray
    }
    
    func fetchProductsData() -> Observable<[ProductModel]> {
        return Observable<[ProductModel]>.create { [unowned self] observer in
            let task = URLSession.shared.dataTask(with: self.baseURL) { data, _, _ in
                do {
                    guard let data = data else { return }
                    let model = try JSONDecoder().decode(MainProductModel.self, from: data)
                    observer.onNext(model.products)
                } catch {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func findProductsData(text: String) -> Observable<[ProductModel]> {
        return Observable<[ProductModel]>.create { [unowned self] observer in
            let urlQueryItem = URLQueryItem(name: "q", value: text)
            let request = URLRequest(
                url: self.baseURL.appendingPathComponent("search")
                    .appending(
                        queryItems: [urlQueryItem]
                    )
            )
            Task {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    let model = try JSONDecoder().decode(MainProductModel.self, from: data)
                    observer.onNext(model.products)
                } catch {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    //Encode method
    func encode<T: Encodable>(data: T) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(data)
    }
    
    //Post method async
    func postProductsData() async throws {
        var encodedProductModel: Data?
        encodedProductModel = try encode(data: encodedProductModel)
        var request = URLRequest(url: baseURL.appendingPathComponent("add"))
        request.httpMethod = "POST"
        request.httpBody = encodedProductModel
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Post response status code: \(httpResponse.statusCode)")
        }
    }
    
    //Put method async
    func putAsync(id: Int) async throws  {
        var encodedProductModel: Data?
        encodedProductModel = try encode(data: encodedProductModel)
        var request = URLRequest(url: baseURL.appendingPathComponent("\(id)"))
        request.httpMethod = "PUT"
        request.httpBody = encodedProductModel
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Put response status code: \(httpResponse.statusCode)")
        }
    }
    
    //Delete async
    func deleteProductsData(id: Int) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("\(id)"))
        request.httpMethod = "DELETE"
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Delete response status code: \(httpResponse.statusCode)")
        }
    }
    
}

