import SwiftUI

struct categorieCard: View {
    let categoryImage: String
    let categoryLable: String
    let numberOfItems: String

    var body: some View {
        VStack(spacing: 10) {

            // Safe image: if asset missing, use SF Symbol fallback
            if !categoryImage.isEmpty, UIImage(named: categoryImage) != nil {
                Image(categoryImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            } else {
                Image(systemName: "tshirt")
                    .font(.system(size: 34, weight: .semibold))
                    .frame(width: 84, height: 84)
                    .background(.white.opacity(0.12))
                    .clipShape(Circle())
            }

            Text(categoryLable)
                .font(.headline)
                .foregroundStyle(.nightBlueShadow)

            Text("\(numberOfItems) in stock")
                .font(.subheadline)
                .foregroundStyle(.nightBlueShadow.opacity(0.85))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 170)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.black.opacity(0.85), lineWidth: 1)
        )
    }
}
