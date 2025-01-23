import Foundation

enum ProductError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case productNotFound(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "Product not found in database"
        case .decodingError:
            return "Failed to parse product data"
        case .serverError(let message):
            return message
        case .productNotFound(let barcode):
            return "Product with barcode \(barcode) not found in database"
        }
    }
}

class ProductService {
    private let baseURL = "https://world.openfoodfacts.org/api/v0"
    
    func fetchProduct(barcode: String) async throws -> Product {
        print("Fetching product with barcode: \(barcode)")
        
        guard let url = URL(string: "\(baseURL)/product/\(barcode).json") else {
            print("Invalid URL")
            throw ProductError.invalidURL
        }
        
        print("Requesting URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw ProductError.serverError("Invalid response")
            }
            
            print("Server responded with status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Server error: \(httpResponse.statusCode)")
                throw ProductError.serverError("Server returned \(httpResponse.statusCode)")
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ProductResponse.self, from: data)
                
                if result.status == 0 {
                    print("Product not found: \(result.statusVerbose ?? "Unknown error")")
                    throw ProductError.productNotFound(barcode)
                }
                
                guard let product = result.product else {
                    print("No product data found")
                    throw ProductError.noData
                }
                
                print("Successfully decoded product: \(product.name)")
                return product
                
            } catch let decodingError as DecodingError {
                print("Decoding error: \(decodingError)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(dataString)")
                }
                throw ProductError.decodingError
            }
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
}

struct ProductResponse: Codable {
    let status: Int
    let product: Product?
    let statusVerbose: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case product
        case statusVerbose = "status_verbose"
    }
} 
