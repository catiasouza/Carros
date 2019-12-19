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
}
