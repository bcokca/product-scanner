import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = product.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                }
                
                Text(product.name)
                    .font(.title)
                
                if let brands = product.brands {
                    Text("Brand: \(brands)")
                        .foregroundColor(.secondary)
                }
                
                if let grade = product.nutritionGrade?.uppercased() {
                    HStack {
                        Text("Nutrition Grade:")
                        Text(grade)
                            .bold()
                            .padding(8)
                            .background(gradeColor(grade))
                            .clipShape(Circle())
                    }
                }
                
                if let ingredients = product.ingredients, !ingredients.isEmpty {
                    Group {
                        Text("Ingredients")
                            .font(.headline)
                        
                        ForEach(ingredients, id: \.id) { ingredient in
                            Text("• \(ingredient.id.replacingOccurrences(of: "-", with: " ").capitalized)")
                        }
                    }
                }
                
                Group {
                    Text("Nutrition Facts (per 100g)")
                        .font(.headline)
                    
                    nutritionRow("Energy", value: product.nutriments.energy, unit: "kcal")
                    nutritionRow("Proteins", value: product.nutriments.proteins, unit: "g")
                    nutritionRow("Carbohydrates", value: product.nutriments.carbohydrates, unit: "g")
                    nutritionRow("Fat", value: product.nutriments.fat, unit: "g")
                    nutritionRow("Sugar", value: product.nutriments.sugar, unit: "g")
                    nutritionRow("Fiber", value: product.nutriments.fiber, unit: "g")
                    nutritionRow("Salt", value: product.nutriments.salt, unit: "g")
                }
            }
            .padding()
        }
    }
    
    private func nutritionRow(_ title: String, value: Double?, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let value = value {
                Text("\(value, specifier: "%.1f")\(unit)")
            } else {
                Text("N/A")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A": return .green
        case "B": return .mint
        case "C": return .yellow
        case "D": return .orange
        case "E": return .red
        default: return .gray
        }
    }
} 
