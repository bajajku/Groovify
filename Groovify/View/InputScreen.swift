//
//  InputScreen.swift
//  Groovify
//
//  Created by Iman on 2024-11-07.
//

import SwiftUI

struct InputScreen: View {
    @State private var searchText = ""
    @State private var selectedEmotions = Set<String>()
    @State private var searchMode: SearchMode = .emotionBased // To toggle between modes
    @State private var searchQuery = ""
    @State private var tracks: [Track] = []
    @State private var errorMessage: String?
    @State private var selectedTrack: Track?
    @Environment(\.spotifyAPI) private var api

    enum SearchMode: String, CaseIterable {
        case emotionBased = "Emotion Search"
        case normalSearch = "Normal Search"
    }
    private func search() {
        api.searchTracks(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self.tracks = tracks
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Search Mode", selection: $searchMode) {
                    ForEach(SearchMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if searchMode == .emotionBased {
                    emotionSearchView
                } else {
                    normalSearchView
                }
            }
            .background(Color(red: 10.0/255.0, green: 14.0/255.0, blue: 69.0/255.0))
        }
    }

    var emotionSearchView: some View {
        VStack {
            Text("Emotions")
                .foregroundColor(.white)

            // Search bar
            HStack {
                TextField("🤩 How are you feeling today?", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(["Happy", "Nostalgic", "Calm", "Excited", "Romantic", "Sad", "Angry", "Anxious", "Lonely", "Grief", "Jealousy", "Regret"], id: \.self) { emotion in
                        Button(action: {
                            if selectedEmotions.contains(emotion) {
                                selectedEmotions.remove(emotion)
                            } else {
                                selectedEmotions.insert(emotion)
                            }
                            print("Selected emotions: \(selectedEmotions)")
                        }) {
                            Text("#\(emotion)")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(selectedEmotions.contains(emotion) ? Color.green : Color.purple)
                                .cornerRadius(10)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }

            NavigationLink(destination: OutputScreen(initialSearchText: searchText)) {
                Text("See Results")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .font(.system(size: 18))
            }
        }
    }

// Add a normal search view,
// TODO: Separate this into a separate view later
    var normalSearchView: some View {
        VStack {
            Text("Normal Search")
                .foregroundColor(.white)
                .padding(.top)

            HStack {
                TextField("Search tracks...", text: $searchQuery, onCommit: search)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            Button(action: search) {
                Text("Search")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .font(.system(size: 18))
            }
            .padding()

            ScrollView {
                TrackListView(tracks: tracks)
            }

            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            api.auth.authenticate { result in
                if case .failure(let error) = result {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    InputScreen()
}
