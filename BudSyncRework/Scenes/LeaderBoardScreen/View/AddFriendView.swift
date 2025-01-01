//
//  AddFriendView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 19/12/24.
//

import SwiftUI

struct AddFriendView: View {
    @State var showQRCode = true
    @State var decodedID = ""
    @State var loadingAction = false
    @Binding var actionResult: Bool?
    @Binding var showAlert: Bool
    
    @Environment(\.dismiss) var dismiss
    private let friendVM = FriendViewModel()
    
    var body: some View {
        ZStack {
            Color.bg
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack {
                    if showQRCode {
                        Image(uiImage: friendVM.generateQRCode())
                            .resizable()
                            .scaledToFit()
                    } else {
                        QRScannerView(
                            decodedQRData: $decodedID,
                            isScanning: $showQRCode,
                            previewFrameSize: UIScreen.main.bounds.width
                        )
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                
                Spacer()
                
                Button {
                    showQRCode.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.primary)
                        .frame(width: UIScreen.main.bounds.width - 75, height: 60)
                        .overlay {
                            Text(showQRCode ? "Scan Friend's QR Code" : "Show Your QR Code")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                        }
                }
                
                Spacer()
            }
            
            if loadingAction {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.5)
                
                if actionResult == nil {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Add New Friends")
        .onChange(of: decodedID) { oldValue, newValue in
            if !decodedID.isEmpty {
                loadingAction = true
                
                Task {
                    let result = await friendVM.addNewFriend(friendID: decodedID)
                    
                    DispatchQueue.main.async {
                        self.actionResult = result
                        self.loadingAction = false
                        
                        withAnimation(.easeIn(duration: 1)) {
                            self.showAlert = true
                        }
                        
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    AddFriendView()
//}
