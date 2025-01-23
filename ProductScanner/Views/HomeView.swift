import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Product Scanner")
                .font(.title)
                .bold()
            
            Text("Scan products to check their ingredients and nutritional information")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
                .frame(height: 30)
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "checkmark.circle.fill",
                          title: "Ingredient Analysis",
                          description: "Check what's in your food")
                
                FeatureRow(icon: "heart.fill",
                          title: "Health Insights",
                          description: "Get nutritional information")
                
                FeatureRow(icon: "exclamationmark.triangle.fill",
                          title: "Allergen Alerts",
                          description: "Identify potential allergens")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
