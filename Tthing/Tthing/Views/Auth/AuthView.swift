//
//  AuthView.swift
//  Tthing
//
//  Created by sookim on 10/31/25.
//

import SwiftUI

enum AuthType {
    case login
    case register
}

struct AuthView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @FocusState private var isEmailFocused
    @FocusState private var isPassFocused
    @FocusState private var isConfirmPassFocused
    
    @State private var showPass = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var authType: AuthType = .login
     
    var body: some View {
        ScrollView(showsIndicators: false) {
            TopView()
            SegmentedView(authType: $authType)
            
            VStack(spacing: 15) {
                TextField(text: $email) {
                    Text("Email")
                }
                .focused($isEmailFocused)
                .textFieldStyle(AuthTextFieldStyle(isFocused: $isEmailFocused))
                
                
                ZStack {
                    TextField(text: $password) {
                        Text("Password")
                    }
                    .focused($isPassFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isPassFocused))
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showPass.toggle()
                            }
                        } label: {
                            Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                                .padding()
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
                    .opacity(showPass ? 1 : 0)
                    .zIndex(1)
                    
                    SecureField(text: $password) {
                        Text("Password")
                    }
                    .focused($isPassFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isPassFocused))
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showPass.toggle()
                            }
                        } label: {
                            Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                                .padding()
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
                    .opacity(showPass ? 0 : 1)
                }
                
                if authType == .register {
                    ZStack {
                        TextField(text: $confirmPassword) {
                            Text("Password Confirm")
                        }
                        .focused($isConfirmPassFocused)
                        .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPassFocused))
                        .overlay(alignment: .trailing) {
                            Button {
                                withAnimation {
                                    showPass.toggle()
                                }
                            } label: {
                                Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                                    .padding()
                                    .foregroundStyle(Color(UIColor.lightGray))
                            }
                        }
                        .opacity(showPass ? 1 : 0)
                        .zIndex(1)
                        
                        SecureField(text: $confirmPassword) {
                            Text("Password Confirm")
                        }
                        .focused($isConfirmPassFocused)
                        .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPassFocused))
                        .overlay(alignment: .trailing) {
                            Button {
                                withAnimation {
                                    showPass.toggle()
                                }
                            } label: {
                                Image(systemName: showPass ? "eye.fill" : "eye.slash.fill")
                                    .padding()
                                    .foregroundStyle(Color(UIColor.lightGray))
                            }
                        }
                        .opacity(showPass ? 0 : 1)
                    }
                }
            }
            
            Button {
                if password != confirmPassword {
                  return
                }
                
                Task {
                    if authType == .login {
                        await authViewModel.login(email: email, password: password)
                    } else {
                        await authViewModel.register(email: email, password: password)
                    }
                    
                    if authViewModel.isAuthenticated {
                        dismiss()
                    }
                }
            } label: {
                Text(authType == .login ? "Login" : "Register")
            }
            .buttonStyle(AuthButtonType())
            
            BottomView(authType: $authType)
        }
        .padding()
        .gesture(
            TapGesture()
                .onEnded({
                    isEmailFocused = false
                    isPassFocused = false
                    isConfirmPassFocused = false
                })
        )
    }
}

struct AuthButtonType: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .foregroundStyle(Color.white)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .background(
                LinearGradient(stops: [
                    .init(color: .mint, location: 0.0),
                    .init(color: .blue, location: 1.0),
                ],
                               startPoint: .leading,
                               endPoint: .trailing)
            )
            .cornerRadius(15)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .padding(.vertical, 12)
    }
}

struct AuthTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    let isFocused: FocusState<Bool>.Binding
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFocused.wrappedValue ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                        .zIndex(1)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(colorScheme == .light ? Color(.white) : Color(uiColor: UIColor.darkGray))
                        .zIndex(0)
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
            .textInputAutocapitalization(.never)
    }
    
}

struct TopView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
            
            Text("Tthing")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
        }
    }
}

struct SegmentedView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var authType: AuthType
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    self.authType = .login
                }
            } label: {
                Text("Login")
                    .fontWeight(authType == .login ? .semibold : .regular)
                    .foregroundStyle(authType == .login ? (colorScheme == .light ? Color(.black) : Color(.white)) : .gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, authType == .login ? 30 : 20)
                    .background {
                        ZStack {
                            if authType == .login {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                                    .zIndex(1)
                            }
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(authType == .login ? Color(UIColor.systemGray5) : Color(uiColor: UIColor.systemGray6))
                                .zIndex(0)
                        }
                    }
            }
            
            Button {
                withAnimation {
                    self.authType = .register
                }
            } label: {
                Text("Register")
                    .fontWeight(authType == .register ? .semibold : .regular)
                    .foregroundStyle(authType == .register ? (colorScheme == .light ? Color(.black) : Color(.white)) : .gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, authType == .register ? 30 : 20)
                    .background {
                        ZStack {
                            if authType == .register {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                                    .zIndex(1)
                            }
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(authType == .register ? Color(UIColor.systemGray5) : Color(uiColor: UIColor.systemGray6))
                                .zIndex(0)
                        }
                    }
            }
        }
        .background(
            Color(UIColor.systemGray6)
        )
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
    }
}

struct BottomView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var authType: AuthType
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 3) {
                Text(authType == .login ? "Don't have an account?" : "Already have an account?")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                
                Button {
                    if authType == .login {
                        withAnimation {
                            authType = .register
                        }
                    } else {
                        withAnimation {
                            authType = .login
                        }
                    }
                } label: {
                    Text(authType == .login ? "Register" : "Login")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
            }
        }
    }
    
}

