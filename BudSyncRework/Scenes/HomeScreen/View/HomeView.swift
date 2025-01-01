//
//  HomeView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 22/12/24.
//

import SwiftUI

struct HomeView: View {
    @State var showSheet = false
    @State var enableInput = false
    @State var state: TrackerState = .Progress
    @State var showToast = false
    
    @ObservedObject var homeVM = HomeViewModel.shared
    @State var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bg
                    .ignoresSafeArea()
                
                VStack {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        ProfileCardView()
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    TabView(selection: $state) {
                        ForEach(TrackerState.allCases, id: \.self) { state in
                            TrackerView(
                                showSheet: $showSheet,
                                enableInput: $enableInput,
                                state: state
                            )
                        }
                    }
                    .tabViewStyle(.page)
                    
                    Spacer()
                }
                
                if homeVM.showToast {
                    if homeVM.inputResult {
                        ToastView(
                            message: "Successfully input data.",
                            success: true
                        )
                    } else {
                        ToastView(
                            message: "Failed Inputing Data",
                            success: false
                        )
                    }
                }
            }
        }
        .onAppear {
            homeVM.setUpViewModel()
        }
        .sheet(isPresented: $showSheet) {
            DetailSheetView(state: state)
        }
        .sheet(isPresented: $enableInput) {
            TrackerInputView(showInput: $enableInput)
        }
        .onChange(of: homeVM.showToast) { oldValue, newValue in
            if homeVM.showToast {
                timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    withAnimation(.easeOut(duration: 1)) {
                        homeVM.showToast = false
                    }
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
    }
}

//#Preview {
//    HomeView()
//}
