//
//  dashCards.swift
//  stockCount
//
//  Created by Mohamed Kaid on 11/14/25.
//

import SwiftUI

struct dashCards: View {
    
    @State var itemNumber: String
    @State var str: String
    var body: some View {
        VStack(alignment:.leading, spacing: 5){
            Text(self.itemNumber)
                .font(.system(size: 40))
            Text(self.str)
                .font(.subheadline)
        }
        .frame(maxWidth: 200, maxHeight: 150)
        .foregroundStyle(Color.nightBlueShadow)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.85))
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 0.5)
        )
        
    }
}

#Preview {
    dashCards(itemNumber:"127", str:"Total Items")
}
