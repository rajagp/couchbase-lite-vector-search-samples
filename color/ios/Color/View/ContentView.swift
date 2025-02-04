//
//  ContentView.swift
//  Color
//
//  Copyright (c) 2024 Couchbase, Inc All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ContentViewModel
    
    @State var searchColor = ""
    @State var displayColor = Color(.white)
    
    @State private var displayError = false
    @State private var errorMessage = ""
    
    @FocusState private var isFocused :Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        TextField("Color Code (FF0000 or 255 0 0)", text: $searchColor)
                            .frame(height: 44).padding(.horizontal, 10)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .onSubmit {
                                if (searchColor.count > 0) {
                                    isFocused = false
                                    search()
                                }
                            }
                    }
                    .background(Color.white)
                    
                    Text("")
                        .frame(width: 44, height: 44)
                        .background(displayColor)
                }
                .padding(10)
                .background(Color.white)
                
                List(model.colors) { color in
                    ColorRow(color: color)
                }
                .listStyle(.plain)
                Spacer()      
            }
            .navigationTitle("Color")
            .alert("Error", isPresented: $displayError) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text(errorMessage)
            }
        }
        .task {
            do {
                try await model.initialize()
            } catch {
                displayError(error)
            }
        }
    }
    
    func search() {
        Task {
            do {
                let rgb = try RGB.vector(for: searchColor)
                displayColor = Color(rgb: rgb)
                try await model.search(rgb)
            } catch {
                displayError(error)
            }
        }
    }
    
    func displayError(_ error: Error) {
        errorMessage = "\(error)"
        displayError = true
    }
}

#Preview {
    let model = ContentViewModel(AppService())
    model.colors = [
        ColorObject(id: "#FF0000", name: "Red", rgb: [255, 0, 0], distance: 1.0),
        ColorObject(id: "#FFC0CB", name: "Pink", rgb: [255, 192, 203], distance: 2.0)
    ]
    return ContentView(searchColor: "FF0000", displayColor: Color.red).environmentObject(model)
}
