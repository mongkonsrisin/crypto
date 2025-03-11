//
//  ContentView.swift
//  Crypto
//
//  Created by Mongkon on 2025-03-11.
//

import SwiftUI
import Security

struct ContentView: View {
    
    @State private var inputText = ""
    @State private var resultText = ""
    
    var body: some View {
        VStack {
            TextEditor(text: $inputText)
                .font(.system(size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 300)
            
            HStack {
                MyButton.Encrypt(text: "DEV", action: {
                    performEncrypt(with: Constants.DEV.PUBLIC_KEY)
                })
                
                MyButton.Encrypt(text: "UAT", action: {
                    performEncrypt(with: Constants.UAT.PUBLIC_KEY)
                })
                
                MyButton.Decrypt(text: "DEV", action: {
                    performDecrpt(with: Constants.DEV.PRIVATE_KEY)
                })
                
                MyButton.Decrypt(text: "UAT", action: {
                    performDecrpt(with: Constants.UAT.PRIVATE_KEY)
                })
            }
            TextEditor(text: $resultText)
                .font(.system(size: 20))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 300)
        }
        .padding()
    }
    
    func performEncrypt(with key: String) {
        let enc = encryptRSA(text: inputText, key: key)
        resultText = enc
    }
    
    func performDecrpt(with key: String) {
        let enc = decryptRSA(text: inputText.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil), key: key)
        resultText = enc
    }
}


func encryptRSA(text: String, key: String) -> String {
    let keyString = key
        .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
        .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
        .replacingOccurrences(of: "\n", with: "")
    
    guard let keyData = Data(base64Encoded: keyString) else {
        print("Failed to decode base64 public key string")
        return ""
    }
    
    let keyDict: [CFString: Any] = [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits: 2048
    ]
    
    var error: Unmanaged<CFError>?
    guard let publicKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
        print("Failed to create public key: \(String(describing: error))")
        return ""
    }
    
    let plainData = text.data(using: .utf8)!
    
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey,
                                                        .rsaEncryptionPKCS1,
                                                        plainData as CFData,
                                                        &error) as Data? else {
        print("Encryption error: \(String(describing: error))")
        return ""
    }
    
    return encryptedData.base64EncodedString()
}

func decryptRSA(text: String, key: String) -> String {
    guard let encryptedData = Data(base64Encoded: text) else {
        return "Failed to decode base64 encrypted string"
    }
    
    let keyString = key
        .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "\n", with: "")
    
    guard let keyData = Data(base64Encoded: keyString) else {
        return "Failed to decode base64 private key string"
    }
    
    print("Key Data Length: \(keyData.count) bytes")
    
    let keyDict: [CFString: Any] = [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass: kSecAttrKeyClassPrivate,
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
        if let error = error?.takeRetainedValue() {
            return "Failed to create private key: \(error.localizedDescription)"
        } else {
            return "Failed to create private key"
        }
    }
    
    guard let decryptedData = SecKeyCreateDecryptedData(privateKey,
                                                        .rsaEncryptionPKCS1,
                                                        encryptedData as CFData,
                                                        &error) as Data? else {
        return "Decryption error: \(String(describing: error))"
    }
    
    return String(data: decryptedData, encoding: .utf8) ?? ""
}
