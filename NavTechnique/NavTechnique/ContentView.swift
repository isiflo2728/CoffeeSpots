//
//  ContentView.swift
//  NavTechnique
//
//  Created by Isidoro Flores on 4/29/26.
//

import SwiftUI

struct DetailedView: View {
    
    var number: Int

    
    var body: some View {

        NavigationLink("Go to some random number", value: Int.random(in: 1...1000))
            .navigationTitle("Number: \(number)")
    }
}


struct ContentView: View {
    @State private var pathStore = PathStore()
    
    var body: some View {
        NavigationStack(path: $pathStore.path){
            DetailedView(number: 0)
                .navigationDestination(for: Int.self){ i in
                    DetailedView(number: i)
                        
                    
                }
              
        }
   }
}
#Preview {
    ContentView()
}

/*
 Notes:
 
 var body: some View {
     NavigationStack {
         List(0..<100){i in
             NavigationLink("Select \(i)", value: i)
         }
         .navigationDestination(for : Int.self){selection in
             Text("You selected \(selection)")
         }
     }
 }
 
 This is the cool part so the old way of doing things ceeates the views in the background and recreates them as long as the optiion appears on screen, in this it says store a numbner,
 and only creates the view once the option is tapped

 if you have different data types like a string u can keep adding more modifiers to the botoom ti accept different data types
 
 Hashable by adding that keyword to our structs we can conform to the hashable protocoland use structs in navigaiton destination
 
 NavigationStack(path : $path){
     VStack{
         Button("Show 32"){
             path = [32]
         }
         Button("Show 64"){
             path.append(64)
         }
         Button("Show 32 and 64")
         {
             path = [32,64]
         }
         
     }
     .navigationDestination(for: Int.self){ selection in
         Text("You selected \(selection)")
         
     }
 
 The above code is as effecient as before but now we are experiencing path linkingm, what path linking does is that tt lets us go instantly to views with an array, for example in the third button we went two views deep, this can be useful with things like notificaitons

 we used an array of int for stacked navigation but hw can we navigate when we are using multiple data types instead
 BTW this is how different navigaiton destination modifers looks like we have one for int and one for strings
 
 NavigationStack{
     List{
         ForEach(0..<5){ i in
             NavigationLink("Selected number \(i)", value: i)
         }
         ForEach(0..<5){ i in
             NavigationLink("Selection string \(i)", value: String(i))
         }
     }
     .navigationDestination(for: Int.self){ selection in
         Text("You selected the number \(selection)")
         
     }
     .navigationDestination(for: String.self){ selection in
         Text("You selected the string \(selection)")
 }
}
 
 This is how we can append different dtata types
 its called a type eraser it stores hashable data without exposing what type of data it is
 
 @State private var path = NavigationPath()
 
 var body: some View {
     NavigationStack(path: $path) {
         List{
             
         }
         .toolbar{
             Button("Push 56"){
                 path.append(56)
             }
             Button("Push hello"){
                 path.append("Hello")
             }
         }
     }
 
 
 
 
 //struct DetailedView: View {
 
 var number: Int
 @Binding var path: [Int]
 
 var body: some View {

     NavigationLink("Go to some random number", value: Int.random(in: 1...1000))
         .navigationTitle("Number: \(number)")
 }
}


struct ContentView: View {
 @State private var path = [Int]()
 
 var body: some View {
     NavigationStack(path: $path){
         DetailedView(number: 0, path: $path)
             .navigationDestination(for: Int.self){ i in
                 DetailedView(number: i, path: $path)
                     .toolbar{
                     Button("Home"){
                         path.removeAll()
                     }
                 }
                 
             }
           
     }
}
}
#Preview {
 ContentView()
}

 Note on the sandbox here we create views everytime we click the button and thatd fine nothing special
 ut how can we go back home
 well we ad a binding input
  and pass binded path values down
 then we can add a tool bar item to et the array to zeor whoch brings us to the root view
 
 if ur using navigation path then to rest the code would like like this
 
 path = NavigationPath()
 
 */
