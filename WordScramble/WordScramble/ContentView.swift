//
//  ContentView.swift
//  WordScramble
//
//  Created by Ma Xueyuan on 2019/11/10.
//  Copyright © 2019 Ma Xueyuan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            GeometryReader { superGeo in
                VStack {
                    TextField("Enter your word", text: self.$newWord, onCommit: self.addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()
                    
                    List(self.usedWords, id: \.self) { word in
                        GeometryReader { geo in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                    .foregroundColor(Color(red: 0,
                                        green: Double(geo.frame(in: .global).maxY) / Double(superGeo.frame(in: .global).maxY),
                                        blue: 0))
                                
                                Text(word)
                                
                                Spacer()
                            }
                            .offset(x: geo.frame(in: .global).minY >= 400 ? geo.frame(in: .global).minY - 400 : 0)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibility(label: Text("\(word), \(word.count) letters"))
                    }
                    
                    Text("Score: \(self.score)")
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button(action: startGame, label: {
                Text("Restart")
            }))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // debug
        if answer == "debug" {
            usedWords.insert(answer, at: 0)
            score += answer.count
            newWord = ""
            return
        }
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make then up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Word should at least has 3 letters")
            return
        }
        
        guard isDifferentWithStartWord(word: answer) else {
            wordError(title: "Word is same with start word", message: "You can not just copy the start word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += answer.count
        newWord = ""
    }
    
    func startGame() {
        usedWords.removeAll()
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        word.count >= 3
    }
    
    func isDifferentWithStartWord(word: String) -> Bool {
        word != rootWord.lowercased()
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
