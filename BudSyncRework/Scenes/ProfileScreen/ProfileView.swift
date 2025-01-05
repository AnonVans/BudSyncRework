//
//  ProfileView.swift
//  BudSyncRework
//
//  Created by Stevans Calvin Candra on 19/12/24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State var setTracked = true
    @State var setTarget = true
    @State var showGalery = false
    @State var chosenPhoto: PhotosPickerItem?
    @State var showAlert = false
    @State var showToast = false
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var profileVM = ProfileViewModel.shared
    @Binding var needSignUp: Bool
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Image(uiImage: profileVM.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 125, height: 125)
                        .clipShape(Circle())
                        .padding(.vertical)
                    
                    Circle()
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.white)
                        }
                        .offset(x: 40, y: 40)
                }
                .onTapGesture {
                    showGalery.toggle()
                }
                .photosPicker(
                    isPresented: $showGalery,
                    selection: $chosenPhoto,
                    matching: .any(of: [.images, .screenshots])
                )
                .onChange(of: chosenPhoto) { oldValue, newValue in
                    Task {
                        if let photoData = try? await chosenPhoto?.loadTransferable(type: Data.self) {
                            let image = UIImage(data: photoData)
                            profileVM.updateUserProfile(image: image)
                            chosenPhoto = nil
                        }
                    }
                }
                
                List {
                    Section {
                        HStack {
                            Text("Username")
                                .frame(width: 110, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.trailing, 30)
                            
                            TextField("", text: $profileVM.currUser.username)
                        }
                        
                        HStack {
                            Text("Email")
                                .frame(width: 110, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.trailing, 30)
                            
                            TextField("", text: $profileVM.currUser.email)
                        }
                    } header: {
                        Text("Edit Profile")
                    }
                    
                    Section {
                        ForEach(HealthType.allCases, id: \.self) { type in
                            HStack {
                                Text(type.rawValue)
                                    .frame(width: 110, alignment: .leading)
                                    .padding(.vertical, 5)
                                    .padding(.trailing, 30)
                                
                                TextField(
                                    "",
                                    value: $profileVM.currUser.goals[type.rawValue],
                                    format: .number
                                )
                                .keyboardType(.numberPad)
                            }
                        }
                    } header: {
                        Text("Customize Tracked Field's Targets")
                    }
                }
                .listStyle(.sidebar)
            }
            
            if profileVM.enableSaveChanges {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            profileVM.cancelChanges()
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.blue)
                                .bold()
                                .frame(width: 100, height: 35)
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        Spacer()
                        
                        Button {
                            Task {
                                await profileVM.updateUser()
                                
                                withAnimation(.easeIn(duration: 1)) {
                                    showToast = true
                                }
                            }
                        } label: {
                            Text("Save")
                                .bold()
                                .frame(width: 100, height: 35)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        Spacer()
                    }
                    .frame(height: 100)
                    .background(.white.opacity(0.75))
                }
            }
            
            if showToast {
                if profileVM.updateSuccess {
                    ToastView(
                        message: "Successfully update profile",
                        success: true
                    )
                } else {
                    ToastView(
                        message: "Failed updating profile",
                        success: false
                    )
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onChange(of: profileVM.currUser) { oldValue, newValue in
            profileVM.checkChanges()
        }
        .onChange(of: showToast) { oldValue, newValue in
            if showToast {
                timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    withAnimation(.easeOut(duration: 1)) {
                        showToast = false
                    }
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
        .alert(
            "Are you sure you want to delete your account?",
            isPresented: $showAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        await profileVM.deleteAccount()
                        needSignUp = true
                        dismiss()
                    }
                }
            }
    }
}
