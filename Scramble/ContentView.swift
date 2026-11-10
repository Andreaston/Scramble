//
//  ContentView.swift
//  Scramble
//
//  Created by André on 21/10/2026.
//

//Botón para reiniciar la partida
//Función para no permitir palabras menores a 3
//Mostrar PUNTUACIÓN

import SwiftUI

struct ContentView: View {
    @State private var palabrasUsar = [String]()
    @State private var rutaPalabra = ""
    @State private var nuevaPalabra = ""
    @State private var puntuacion = 0
    
    @State private var errorTitulo = ""
    @State private var errorMensaje = ""
    @State private var showingError = false
    
    var body: some View {
        
        NavigationStack {
            VStack{
                HStack{
                    Button("Nueva Palabra"){
                        starGame()
                    }
                    Text("Puntos: \(puntuacion)")
                }
            }.padding(.horizontal)
            
            List {
                Section {
                    TextField("Escribe tu palabra", text: $nuevaPalabra).textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(palabrasUsar, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text("\(word) - ")
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .navigationTitle(rutaPalabra)
            .onSubmit {
                anhadirPalabra()
            }
            .onAppear(perform: starGame)
            .alert(errorTitulo, isPresented: $showingError){
                Button("OK"){}
            } message: {
                Text(errorMensaje)
            }
        }
    }
    
    func puntuar(palabra: String){
        puntuacion += palabra.count
    }
    
    func anhadirPalabra(){
        let respuesta = nuevaPalabra.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard respuesta.count > 0 else {return}
        
        guard respuesta.count > 2 else {
            errorPalabra(titulo: "Palabra no valida", mensaje: "La palabra es demasiado corta, no puede tener menos de 3 letras")
            return
        }
        
        guard respuesta != rutaPalabra else {
            errorPalabra(titulo: "Palabra repetida", mensaje: "Esa palabra es la que está ya en el enunciado")
            return
        }
        
        guard esOriginal(palabra: respuesta) else {
            errorPalabra(titulo: "Palabra ya usada", mensaje: "SE MAS ORIGINAL!")
            return
        }
        
        guard esPositivo(palabra: respuesta) else {
            errorPalabra(titulo: "Palabra no posible", mensaje: "No puedes escribir \(respuesta)")
            return
        }
        
        guard esReal(palabra: respuesta) else {
            errorPalabra(titulo: "Palabra no reconocida", mensaje: "Es palabra te la has inventado")
            return
        }
        
        withAnimation{
            palabrasUsar.insert(respuesta, at: 0)
        }
        puntuar(palabra: respuesta)
        nuevaPalabra = ""
    }
    
    func starGame(){
        if let palabrasComienzoURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let palabrasComienzo = try? String(contentsOf: palabrasComienzoURL, encoding: .utf8){
                let todasPalabras = palabrasComienzo.components(separatedBy: "\n")
                rutaPalabra = todasPalabras.randomElement() ?? "mfujogndjo"
                return
            }
        }
        
        fatalError("No encontré start.txt")
        
    }
    
    func esOriginal(palabra : String) -> Bool {
        !palabrasUsar.contains(palabra)
    }
    
    func esPositivo(palabra: String) -> Bool {
        var tempPalabra = rutaPalabra
        for tarde in palabra {
            if let pos = tempPalabra.firstIndex(of: tarde){
                tempPalabra.remove(at: pos)
            } else{
                return false
            }
        }
        
        return true
        
    }
    
    func esReal(palabra: String) -> Bool {
        let checkeador = UITextChecker()
        let rango = NSRange(location: 0, length: palabra.utf16.count)
        let misspelledRange = checkeador.rangeOfMisspelledWord(in: palabra, range: rango, startingAt: 0, wrap: false, language: "es")
        return misspelledRange.location == NSNotFound
    }
    
    func errorPalabra(titulo: String, mensaje: String){
        errorTitulo = titulo
        errorMensaje = mensaje
        showingError = true
    }
    
}
    
    #Preview {
        ContentView()
    }

