//
//  REST.swift
//  Carangas
//
//  Created by Catia Miranda de Souza on 16/12/19.
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import Foundation

enum CarError{
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalitorJason
    
}

enum RESTOperation{
    case save
    case update
    case delete
}
class REST  {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    //CRIANDO A SESSION CUSTOMIZADA
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
        
    }()
    
    private static let session = URLSession(configuration: configuration)
    ////////////API 2
    class func loadBrands(onComplete: @escaping([Brand]?) -> Void ){
        
        guard let url = URL(string: "https://fipeapi.appspot.com/api/1/carros/marcas.json") else {
           onComplete(nil)
            return
        }
        //criando tarefa para requisicao
        let dataTask =  session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                   onComplete(nil)
                    return
                }
                if response.statusCode == 200{
                    
                    guard let data = data else{
                        return
                    }
                    
                    do{
                        //Array de carros
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                        print(brands)
                        //for no array
                        for car in brands {
                            onComplete(nil)
                            //print(car.name, car.brand)
                        }
                    }catch{
                        print(error.localizedDescription)
                       onComplete(nil)
                    }
                }else{
                    print("Algum status invalido pelo sevidor")
                   onComplete(nil)
                }
            }else{
                
               onComplete(nil)
            }
        }
        dataTask.resume()
    }
    //**** API 1
    //passo os parametros p poder acessar da carstableview os carros da api
    class func loadCars(onComplete: @escaping([Car]) -> Void , onError: @escaping(CarError)-> Void){
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
            
        }
        
        //criando tarefa para requisicao
        let dataTask =  session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                    
                }
                if response.statusCode == 200{
                    
                    guard let data = data else{
                        
                        return
                        
                    }
                    
                    do{
                        //Array de carros
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        print(cars)
                        //for no array
                        for car in cars{
                            onComplete(cars)
                            //print(car.name, car.brand)
                        }
                    }catch{
                        print(error.localizedDescription)
                        onError(.invalitorJason)
                    }
                }else{
                    print("Algum status invalido pelo sevidor")
                    onError(.responseStatusCode(code: response.statusCode))
                }
            }else{
                
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume()
    }
    //salvando carro criado
    class func save(car: Car, onComplete: @escaping(Bool)-> Void){
        applyOperation(car: car, operation: .save, onComplete: onComplete)
        //        guard let url = URL(string: basePath) else {
        //            onComplete(false)
        //            return
        //
        //        }
        //        var request = URLRequest(url: url)
        //        request.httpMethod = "POST"
        //
        //        guard let json = try? JSONEncoder().encode(car)else{
        //            onComplete(false)
        //            return
        //
        //        }
        //        request.httpBody = json
        //        //quando for fazer post pegue a dataTask onde contem URLrequest
        //        let dataTask = session.dataTask(with: request) { (data, response, error) in
        //            if error == nil{
        //                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else{
        //                    onComplete(false)
        //                    return
        //                }
        //                onComplete(true)
        //            }else{
        //                onComplete(false)
        //            }
        //        }
        //        dataTask.resume()
    }
    class func update(car: Car, onComplete: @escaping(Bool)-> Void){
        applyOperation(car: car, operation: .update, onComplete: onComplete)
        //        let urlString = basePath + "/" + car._id!
        //        guard let url = URL(string: urlString) else {
        //            onComplete(false)
        //            return
        //
        //        }
        //        var request = URLRequest(url: url)
        //        request.httpMethod = "PUT"
        //
        //        guard let json = try? JSONEncoder().encode(car)else{
        //            onComplete(false)
        //            return
        //
        //        }
        //        request.httpBody = json
        //        //quando for fazer post pegue a dataTask onde contem URLrequest
        //        let dataTask = session.dataTask(with: request) { (data, response, error) in
        //            if error == nil{
        //                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else{
        //                    onComplete(false)
        //                    return
        //                }
        //                onComplete(true)
        //            }else{
        //                onComplete(false)
        //            }
        //        }
        //        dataTask.resume()
    }
    class func delete(car: Car, onComplete: @escaping(Bool)-> Void){
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    //Metodo q substitui o q foi comentado , evitando repetica de codigo
    private class func applyOperation(car: Car, operation: RESTOperation,onComplete: @escaping(Bool)-> Void){
        let urlString = basePath + "/" + (car._id ?? "")//verifica se tem id ou nao
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
            
        }
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        
        switch operation {
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        case .delete:
            httpMethod = "DELETE"
            
        }
        request.httpMethod = httpMethod
        guard let json = try? JSONEncoder().encode(car)else{
            onComplete(false)
            return
            
        }
        request.httpBody = json
        //quando for fazer post pegue a dataTask onde contem URLrequest
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil{
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else{
                    onComplete(false)
                    return
                }
                onComplete(true)
            }else{
                onComplete(false)
            }
        }
        dataTask.resume()
    }
}
