import Foundation

struct Product: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let brands: String?
    let ingredients: [Ingredient]?
    let nutriments: Nutriments
    let imageUrl: String?
    let nutritionGrade: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name = "product_name"
        case brands
        case ingredients = "ingredients_hierarchy"
        case nutriments
        case imageUrl = "image_url"
        case nutritionGrade = "nutrition_grade_fr"
    }
}

struct Ingredient: Codable, Equatable {
    let id: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        // Open Food Facts returns ingredients in format "en:ingredient-name"
        self.id = rawString.replacingOccurrences(of: "en:", with: "")
    }
}

struct Nutriments: Codable, Equatable {
    let energy: Double?
    let proteins: Double?
    let carbohydrates: Double?
    let fat: Double?
    let sugar: Double?
    let fiber: Double?
    let salt: Double?
    
    enum CodingKeys: String, CodingKey {
        case energy = "energy-kcal_100g"
        case proteins = "proteins_100g"
        case carbohydrates = "carbohydrates_100g"
        case fat = "fat_100g"
        case sugar = "sugars_100g"
        case fiber = "fiber_100g"
        case salt = "salt_100g"
    }
}
