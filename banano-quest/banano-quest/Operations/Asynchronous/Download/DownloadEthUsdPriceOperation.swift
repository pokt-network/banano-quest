//
//  DownloadEthUsdPriceOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/21/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public enum DownloadEthUsdPriceOperationError: Error {
    case invalidEndpoint
    case invalidResponse
}

struct CMCEthereumTickerQuote: Decodable {
    let price: Double?
    
    private enum CodingKeys: String, CodingKey {
        case price
    }
}

struct CMCEthereumTickerQuotes: Decodable {
    let usd: CMCEthereumTickerQuote?
    
    private enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

struct CMCEthereumTickerData: Decodable {
    let quotes: CMCEthereumTickerQuotes?
    
    private enum CodingKeys: String, CodingKey {
        case quotes
    }
}

struct CMCEthereumTicker: Decodable {
    let data: CMCEthereumTickerData?
    
    private enum CodingKeys: String, CodingKey {
        case data
    }
}

public class DownloadEthUsdPriceOperation: AsynchronousOperation {
    
    public var usdPrice: Double?
    public var lastUpdated: Date?
    private let priceApiURL = URL(string: "https://api.coinmarketcap.com/v2/ticker/1027")
    
    open override func main() {
        
        guard let urlEndpoint = priceApiURL else {
            self.error = DownloadEthUsdPriceOperationError.invalidEndpoint
            self.finish()
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlEndpoint) {(data, response, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            guard let data = data else {
                self.error = DownloadEthUsdPriceOperationError.invalidResponse
                self.finish()
                return
            }
            
            do {
                let ethereumTicker = try JSONDecoder().decode(CMCEthereumTicker.self, from: data)
                self.usdPrice = ethereumTicker.data?.quotes?.usd?.price
                self.finish()
                //self.lastUpdated = ethereumTicker.lastUpdated
            } catch {
                self.error = error
                self.finish()
            }
        }
        task.resume()
    }
}
