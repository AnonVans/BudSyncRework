//
//  SignInView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 12/12/24.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Binding var finishSignUp: Bool
    private let signInVM = SignInViewModel()
    private let healthMng = HealthKitManager.shared
    
    var body: some View {
        ZStack {
            Image("BackGround")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Make Health Tracking Easy with BudSync")
                    .font(.largeTitle)
                    .bold()
                    .frame(width: 250, alignment: .leading)
                    .padding(.leading, -75)
                
                Spacer()
                Spacer()
                
                SignInWithAppleButton(.signUp) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    switch result {
                        case .success(let auth):
                            Task {
                                await signInVM.handleSignInAuthorization(authorization: auth)
                                await healthMng.requestAuthorization()
                                finishSignUp = false
                            }
                        case .failure(let error):
                            print("Error signing in: \(error)")
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 50)

                Spacer()
            }
        }
    }
}
