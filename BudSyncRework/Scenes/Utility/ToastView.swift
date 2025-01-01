//
//  ToastView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 30/12/24.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var success: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: success ? "checkmark.circle" : "exclamationmark.circle")
                    .font(.title2)
                    .foregroundStyle(success ? .green : .red)
                
                Text(message)
                    .padding(.trailing, 5)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(success ? .green : .red)
            }
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 150)
        }
    }
}

#Preview {
    ToastView(message: "Sucessfully added", success: true)
}
