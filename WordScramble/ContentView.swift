//
//  ContentView.swift
//  WordScramble
//
//  Created by Sedat Çakır on 10.08.2022.
//

import SwiftUI




struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
   
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    Text("Score: \(score)")
                }
                
                Section{
                    ForEach(usedWords, id:\.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
            }
            .navigationTitle(rootWord)
            .toolbar{
                ToolbarItem(placement: .bottomBar){
                Button("Start Game"){
                    startGame()
                }
            }
        }
            .onSubmit {
                addNewWord()
            }
        } .onAppear(perform: startGame)
            
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel){}
            } message : {
                Text(errorMessage)
            }
    }
    

    
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isLessThanThreeLetters(word: answer) else {
            wordError(title: "You can not enter less than 3 letters", message: "You can not do that")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        guard isStartSame(word: answer) else {
            wordError(title: "You can not start like that", message: "You can not do that")
            return
        }
        
       
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        
        score += answer.count + usedWords.count
        
    }
    
    func startGame(){
        score = 0
        usedWords.removeAll()
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkWorm"
                return
                
            }
        }
        
        
        fatalError("Could not load start.txt from bundle.")
        
        
    }
    
    func isLessThanThreeLetters(word:String) -> Bool {
        if word.count < 3{
            return false
        }
        else{
            return true
        }
        
    }
    
    func isStartSame(word:String) -> Bool {
        let tempWord = rootWord.prefix(word.count)
        if tempWord == word{
            return false
        }
        return true
    }
    
    func isOriginal(word:String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
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
