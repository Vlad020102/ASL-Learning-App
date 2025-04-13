////
////  WikiView.swift
////  asl-mobile-app
////
////  Created by v1ad_ach1m on 13.04.2025.
////
//
//import SwiftUI
//
//// MARK: - Models
//struct Phrase: Identifiable, Hashable {
//   let id = UUID()
//   let text: String
//   let translation: String
//   let difficulty: Int // 1-5
//   let price: Int
//   var isPurchased: Bool
//   var signs: [Sign]
//}
//
//// MARK: - View Models
//
//class WikiViewModel: ObservableObject {
//   @Published var currency = 100
//   @Published var signs: [Sign] = [
//       Sign(
//           name: "Hello",
//           meaning: "A greeting",
//           s3Url: "how-are-you",
//           difficulty: 1,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Thank you",
//           meaning: "Expression of gratitude",
//           s3Url: "how-are-you",
//           difficulty: 2,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Please",
//           meaning: "Making a polite request",
//           s3Url: "how-are-you",
//           difficulty: 2,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Name",
//           meaning: "What you are called",
//           s3Url: "how-are-you",
//           difficulty: 1,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Friend",
//           meaning: "A person you know well and like",
//           s3Url: "how-are-you",
//           difficulty: 3,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Family",
//           meaning: "Group of related people",
//           s3Url: "how-are-you",
//           difficulty: 3,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Help",
//           meaning: "To assist someone",
//           s3Url: "how-are-youn",
//           difficulty: 2,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       ),
//       Sign(
//           name: "Learn",
//           meaning: "To gain knowledge",
//           s3Url: "how-are-you",
//           difficulty: 4,
//           explanations: [
//               "Position your hand(s) as shown in the animation",
//               "Pay attention to the orientation of your palm",
//               "Understand the movement and the gesture made",
//               "Try and say the word as you do the gesture"
//           ]
//       )
//   ]
//   
//   @Published var phrases: [Phrase] = [
//       Phrase(
//           text: "My name is...",
//           translation: "Introduction phrase",
//           difficulty: 1,
//           price: 0,
//           isPurchased: true,
//           signs: []
//       ),
//       Phrase(
//           text: "Nice to meet you",
//           translation: "Greeting when meeting someone new",
//           difficulty: 2,
//           price: 15,
//           isPurchased: false,
//           signs: []
//       ),
//       Phrase(
//           text: "How are you?",
//           translation: "Asking about someone's wellbeing",
//           difficulty: 2,
//           price: 15,
//           isPurchased: false,
//           signs: []
//       ),
//       Phrase(
//           text: "I am learning ASL",
//           translation: "Stating that you're studying ASL",
//           difficulty: 3,
//           price: 25,
//           isPurchased: false,
//           signs: []
//       ),
//       Phrase(
//           text: "Can you help me practice?",
//           translation: "Asking for assistance with practice",
//           difficulty: 4,
//           price: 40,
//           isPurchased: false,
//           signs: []
//       )
//   ]
//   
//   init() {
//       // Connect phrases with their signs
//       updatePhraseSignConnections()
//   }
//   
//   func updatePhraseSignConnections() {
//       // This is a simplified example - in a real app, you'd have a more sophisticated matching system
//       phrases[0].signs = [signs[0], signs[3]] // "My name is..."
//       phrases[1].signs = [signs[0], signs[4]] // "Nice to meet you"
//       phrases[2].signs = [signs[0], signs[6]] // "How are you?"
//       phrases[3].signs = [signs[0], signs[7]] // "I am learning ASL"
//       phrases[4].signs = [signs[2], signs[6]] // "Can you help me practice?"
//   }
//   
//   func purchasePhrase(_ phrase: Phrase) -> Bool {
//       guard let index = phrases.firstIndex(where: { $0.id == phrase.id }) else { return false }
//       
//       if currency >= phrase.price {
//           currency -= phrase.price
//           phrases[index].isPurchased = true
//           return true
//       }
//       return false
//   }
//}
//
//// MARK: - Views
//
//struct WikiView: View {
//   @StateObject private var viewModel = WikiViewModel()
//   
//   var body: some View {
//       TabView {
//           PhrasesView()
//               .environmentObject(viewModel)
//               .tabItem {
//                   Label("Phrases", systemImage: "text.bubble")
//               }
//           
//           SignsView()
//               .environmentObject(viewModel)
//               .tabItem {
//                   Label("Signs", systemImage: "hand.raised")
//               }
//       }
//   }
//}
//
//struct PhrasesView: View {
//   @EnvironmentObject private var viewModel: WikiViewModel
//   
//   var body: some View {
//       NavigationView {
//           List {
//               ForEach(viewModel.phrases) { phrase in
//                   NavigationLink(destination: PhraseDetailView(phrase: phrase)) {
//                       HStack {
//                           VStack(alignment: .leading) {
//                               Text(phrase.text)
//                                   .font(.headline)
//                               
//                               Text("Difficulty: \(String(repeating: "★", count: phrase.difficulty))")
//                                   .font(.caption)
//                                   .foregroundColor(.orange)
//                           }
//                           
//                           Spacer()
//                           
//                           if phrase.isPurchased {
//                               Image(systemName: "checkmark.circle.fill")
//                                   .foregroundColor(.green)
//                           } else {
//                               Button(action: {
//                                   _ = viewModel.purchasePhrase(phrase)
//                               }) {
//                                   HStack {
//                                       Text("\(phrase.price)")
//                                           .fontWeight(.bold)
//                                       
//                                       Image(systemName: "dollarsign.circle.fill")
//                                           .foregroundColor(.yellow)
//                                   }
//                                   .padding(8)
//                                   .background(Color.blue.opacity(0.2))
//                                   .cornerRadius(8)
//                               }
//                               .disabled(viewModel.currency < phrase.price)
//                           }
//                       }
//                       .padding(.vertical, 4)
//                   }
//                   .disabled(!phrase.isPurchased)
//               }
//           }
//           .navigationTitle("ASL Phrases")
//           .toolbar {
//               ToolbarItem(placement: .navigationBarTrailing) {
//                   HStack {
//                       Text("\(viewModel.currency)")
//                           .fontWeight(.bold)
//                       
//                       Image(systemName: "dollarsign.circle.fill")
//                           .foregroundColor(.yellow)
//                   }
//               }
//           }
//       }
//   }
//}
//
//struct PhraseDetailView: View {
//   let phrase: Phrase
//   
//   var body: some View {
//       ScrollView {
//           VStack(alignment: .leading, spacing: 20) {
//               // Header section
//               VStack(alignment: .leading, spacing: 8) {
//                   Text(phrase.text)
//                       .font(.largeTitle)
//                       .fontWeight(.bold)
//                   
//                   Text(phrase.translation)
//                       .font(.subheadline)
//                       .foregroundColor(.secondary)
//                   
//                   Text("Difficulty: \(String(repeating: "★", count: phrase.difficulty))")
//                       .font(.caption)
//                       .foregroundColor(.orange)
//               }
//               .padding()
//               .frame(maxWidth: .infinity, alignment: .leading)
//               .background(Color.blue.opacity(0.1))
//               .cornerRadius(12)
//               
//               // Signs used in this phrase
//               Text("Signs in this phrase")
//                   .font(.headline)
//                   .padding(.horizontal)
//               
//               ForEach(phrase.signs) { sign in
//                   SignCardView(sign: sign)
//                       .padding(.horizontal)
//               }
//               
//               // How to sign this phrase
//               Text("How to sign this phrase")
//                   .font(.headline)
//                   .padding(.horizontal)
//                   .padding(.top)
//               
//               VStack(alignment: .leading, spacing: 12) {
//                   Text("1. Start with your dominant hand in neutral position")
//                   Text("2. Sign each word in sequence, maintaining flow")
//                   Text("3. Use appropriate facial expressions to convey meaning")
//                   Text("4. Practice the transitions between signs for fluidity")
//               }
//               .padding()
//               .background(Color.gray.opacity(0.1))
//               .cornerRadius(12)
//               .padding(.horizontal)
//               
//               // Practice button
//               Button(action: {
//                   // Future implementation for practice feature
//               }) {
//                   Text("Practice this phrase")
//                       .fontWeight(.semibold)
//                       .frame(maxWidth: .infinity)
//                       .padding()
//                       .background(Color.blue)
//                       .foregroundColor(.white)
//                       .cornerRadius(10)
//               }
//               .padding()
//           }
//       }
//       .navigationTitle("Learn Phrase")
//       .navigationBarTitleDisplayMode(.inline)
//   }
//}
//
//struct SignCardView: View {
//   let sign: Sign
//   
//   var body: some View {
//       VStack(alignment: .leading) {
//           HStack(alignment: .top) {
//               // Placeholder for GIF - in a real app, you'd use a GIF player
//               ZStack {
//                   Rectangle()
//                       .fill(Color.gray.opacity(0.2))
//                       .aspectRatio(1, contentMode: .fit)
//                       .frame(width: 100, height: 100)
//                   
//                   Text("GIF")
//                       .font(.caption)
//                       .foregroundColor(.gray)
//               }
//               
//               VStack(alignment: .leading, spacing: 6) {
//                   Text(sign.name)
//                       .font(.headline)
//                   
//                   Text(sign.meaning)
//                       .font(.subheadline)
//                       .foregroundColor(.secondary)
//                   
//                   Text("Difficulty: \(String(repeating: "★", count: sign.difficulty))")
//                       .font(.caption)
//                       .foregroundColor(.orange)
//                   
//                   Text("Tap to see details")
//                       .font(.caption)
//                       .foregroundColor(.blue)
//                       .padding(.top, 4)
//               }
//               .padding(.leading, 8)
//               
//               Spacer()
//           }
//       }
//       .padding()
//       .background(Color.white)
//       .cornerRadius(12)
//       .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//   }
//}
//
//struct SignsView: View {
//   @EnvironmentObject private var viewModel: WikiViewModel
//   @State private var searchText = ""
//   
//   var filteredSigns: [Sign] {
//       if searchText.isEmpty {
//           return viewModel.signs
//       } else {
//           return viewModel.signs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
//       }
//   }
//   
//   var body: some View {
//       NavigationView {
//           List {
//               ForEach(filteredSigns) { sign in
//                   NavigationLink(destination: SignDetailView(sign: sign)) {
//                       HStack {
//                           // Small thumbnail for the sign
//                           ZStack {
//                               Circle()
//                                   .fill(Color.blue.opacity(0.1))
//                                   .frame(width: 50, height: 50)
//                               
//                               Text(String(sign.name.prefix(1)))
//                                   .font(.title2)
//                                   .foregroundColor(.blue)
//                           }
//                           
//                           VStack(alignment: .leading) {
//                               Text(sign.name)
//                                   .font(.headline)
//                               
//                               Text(sign.meaning)
//                                   .font(.caption)
//                                   .foregroundColor(.secondary)
//                           }
//                           .padding(.leading, 8)
//                           
//                           Spacer()
//                           
//                           Text("Difficulty: \(String(repeating: "★", count: sign.difficulty))")
//                               .font(.caption)
//                               .foregroundColor(.orange)
//                       }
//                       .padding(.vertical, 4)
//                   }
//               }
//           }
//           .searchable(text: $searchText, prompt: "Search signs")
//           .navigationTitle("All Discovered Signs")
//       }
//   }
//}
//
//struct SignDetailView: View {
//   let sign: Sign
//   @Environment(\.presentationMode) var presentationMode
//   
//   var body: some View {
//       ScrollView {
//           VStack(spacing: 20) {
//               // GIF player (placeholder)
//               ZStack {
//                   Rectangle()
//                       .fill(Color.gray.opacity(0.1))
//                       .aspectRatio(1.0, contentMode: .fit)
//                       .frame(maxWidth: .infinity)
//                       .cornerRadius(12)
//                   
//                   Text("GIF: \(sign.gifName)")
//                       .font(.caption)
//                       .foregroundColor(.gray)
//               }
//               .padding(.horizontal)
//               
//               // Sign information
//               VStack(alignment: .leading, spacing: 12) {
//                   Text(sign.name)
//                       .font(.largeTitle)
//                       .fontWeight(.bold)
//                   
//                   Text(sign.meaning)
//                       .font(.title3)
//                       .foregroundColor(.secondary)
//                   
//                   Divider()
//                   
//                   Text("Difficulty: \(String(repeating: "★", count: sign.difficulty))")
//                       .font(.headline)
//                       .foregroundColor(.orange)
//                   
//                   Text("How to perform this sign:")
//                       .font(.headline)
//                       .padding(.top, 8)
//                   
//                   VStack(alignment: .leading, spacing: 8) {
//                       Text("1. Position your hand(s) as shown in the animation")
//                       Text("2. Pay attention to the orientation of your palm")
//                       Text("3. Understand the movement and the gesture made")
//                       Text("4. Try and say the word as you do the gesture")
//                   }
//                   .padding(.leading)
//                   
//                   Divider()
//                   
//                   Text("Used in these phrases:")
//                       .font(.headline)
//                       .padding(.top, 8)
//                   
//                   // Would be dynamically generated based on phrases using this sign
//                   Text("• My name is...")
//                   Text("• Nice to meet you")
//               }
//               .padding()
//               
//               // Practice button
//               Button(action: {
//                   // Future implementation for practice feature
//               }) {
//                   Text("Practice this sign")
//                       .fontWeight(.semibold)
//                       .frame(maxWidth: .infinity)
//                       .padding()
//                       .background(Color.blue)
//                       .foregroundColor(.white)
//                       .cornerRadius(10)
//               }
//               .padding()
//               
//               // "Find more phrases" button
//               Button(action: {
//                   presentationMode.wrappedValue.dismiss()
//               }) {
//                   Text("Find more signs")
//                       .fontWeight(.medium)
//                       .frame(maxWidth: .infinity)
//                       .padding()
//                       .background(Color.gray.opacity(0.2))
//                       .foregroundColor(.main)
//                       .cornerRadius(10)
//               }
//               .padding(.horizontal)
//               .padding(.bottom)
//           }
//       }
//       .navigationTitle("Sign Detail")
//       .navigationBarTitleDisplayMode(.inline)
//   }
//}
//
