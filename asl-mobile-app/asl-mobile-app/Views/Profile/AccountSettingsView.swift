//
//  AccountSettingsView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 21.03.2025.
//


import SwiftUI

struct AccountSettingsView: View {
    @State private var name: String = "Rajarshi Bashyas"
    @State private var username: String = "RajarshiBa16"
    @State private var email: String = "rajarshidsd@gmail.com"
    @State private var facebookConnected: Bool = false
    @State private var googleConnected: Bool = true
    @State private var soundEffects: Bool = true
    @State private var animations: Bool = true
    @State private var darkMode: String = "OFF"
    @State private var motivationalMessages: Bool = true
    @State private var listeningExercises: Bool = false
    @State private var showingImagePicker: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Save Changes Button
                HStack {
                    Spacer()
                    Button(action: {
                        // Save changes action
                    }) {
                        Text("SAVE CHANGES")
                            .font(.headline)
                            .foregroundColor(Color.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                
                // Profile Picture
                HStack(alignment: .top, spacing: 16) {
                    Text("Profile picture")
                        .font(.headline)
                        .frame(width: 120, alignment: .trailing)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("CHOOSE FILE")
                                .font(.headline)
                                .foregroundColor(Color.blue)
                                .padding()
                                .frame(width: 180)
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        
                        Text("no file selected")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("maximum image size is 1 MB")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Profile Info Fields
                FormField(label: "Name", text: $name)
                FormField(label: "Username", text: $username)
                FormField(label: "Email", text: $email)
                
                // Connect Toggle Fields
                ToggleField(label: "Facebook Connect", isOn: $facebookConnected)
                ToggleField(label: "Google Connect", isOn: $googleConnected)
                ToggleField(label: "Sound effects", isOn: $soundEffects)
                ToggleField(label: "Animations", isOn: $animations)
                
                // Dark Mode Dropdown
                HStack(alignment: .center, spacing: 16) {
                    Text("Dark mode")
                        .font(.headline)
                        .frame(width: 120, alignment: .trailing)
                    
                    Menu {
                        Button("ON", action: { darkMode = "ON" })
                        Button("OFF", action: { darkMode = "OFF" })
                        Button("System", action: { darkMode = "System" })
                    } label: {
                        HStack {
                            Text(darkMode)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(height: 50)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // More Toggle Fields
                ToggleField(label: "Motivational messages", isOn: $motivationalMessages)
                ToggleField(label: "Listening exercises", isOn: $listeningExercises)
                
                // Action Buttons
                VStack(spacing: 16) {
                    ActionButton(title: "LOGOUT", color: .gray)
                    ActionButton(title: "EXPORT MY DATA", color: .gray)
                    ActionButton(title: "DELETE MY ACCOUNT", color: .red)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            Text("Image picker would go here")
                .padding()
        }
    }
}

struct FormField: View {
    var label: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.headline)
                .frame(width: 120, alignment: .trailing)
            
            TextField("", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(height: 50)
        }
        .padding(.horizontal)
    }
}

struct ToggleField: View {
    var label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.headline)
                .frame(width: 120, alignment: .trailing)
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.horizontal)
    }
}

struct ActionButton: View {
    var title: String
    var color: Color
    
    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
}


struct AccountPreview: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
