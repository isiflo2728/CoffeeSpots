//
//  paths.swift
//  NavTechnique
//
//  Created by Isidoro Flores on 4/29/26.
//
import SwiftUI
import Foundation

@Observable
class PathStore{
    var path : [Int]{
        didSet {
            save()
        }
    }
    
    private let savePath = URL.documentsDirectory.appending(path: "SavedPath")
    
    init() {
        if let data = try? Data(contentsOf: savePath) {
            if let decoded = try? JSONDecoder().decode([Int].self, from: data){
                path = decoded
                
                return
            }
        }
        
        path = []
    }
    
    func save (){
        do {
            let data = try JSONEncoder().encode(path)
            try data.write(to: savePath)
        } catch {
            print("Failed to save navigation data")
        }
    }
}

/*
 var path : NavigationPath{
 didSet()
 
 }
 
 if let decoded = try?
 JSONDecoder().decode(NavigationPath.CodableRepresentation.self,
 from: data) {
 path = NavigationPath(decoded)
 return
 }
 path = NavigationPath()
 
 in our save methd
 
 guard let representation = path.codable else { return }
 let data = try JSONEncoder().encode(representation)
 
 
 complete class looks like this
 
 
 @Observable
 class PathStore {
 var path: NavigationPath {
 didSet {
 save()
 }
 }
 private let savePath = URL.documentsDirectory.appending(path:
 "SavedPath")
 init() {
 if let data = try? Data(contentsOf: savePath) {
 if let decoded = try?
 JSONDecoder().decode(NavigationPath.CodableRepresentation.self,
 from: data) {
 path = NavigationPath(decoded)
 return
 }
 }
 // Still here? Start with an empty path.
 path = NavigationPath()
 }
 func save() {
 guard let representation = path.codable else { return }
 do {
 let data = try JSONEncoder().encode(representation)
 try data.write(to: savePath)} catch {
 print("Failed to save navigation data")
 }
 }
 }
 
 */
