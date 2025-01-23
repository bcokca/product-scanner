import SwiftUI

struct HistoryView: View {
    // We'll implement proper history storage later
    @State private var scannedProducts: [Product] = []
    
    var body: some View {
        NavigationView {
            Group {
                if scannedProducts.isEmpty {
                    ContentUnavailableView(
                        "No Scan History",
                        systemImage: "clock",
                        description: Text("Products you scan will appear here")
                    )
                } else {
                    List(scannedProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductRow(product: product)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack {
            if let imageUrl = product.imageUrl,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                if let brand = product.brands {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
