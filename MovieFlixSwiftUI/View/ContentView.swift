//
//  ContentView.swift
//  MovieFlixSwiftUI
//
//  Created by Angelos Staboulis on 15/9/25.
//d8d8c423

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: MovieViewModel
    @State var isSearching:Bool
    init(apiKey: String,isSearching:Bool) {
        _viewModel = StateObject(wrappedValue: MovieViewModel(service: NetworkService(apiKey: apiKey)))
        self.isSearching = isSearching
    }
   

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search movies...", text: $viewModel.searchText, onCommit: {
                        Task {
                            await viewModel.searchMovies()
                            isSearching = true
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    Button("Search") {
                        Task {
                            await viewModel.searchMovies()
                            isSearching = true
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top)

                if viewModel.isLoading {
                    ProgressView("Loading…")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            Task {
                                if viewModel.searchText.isEmpty {
                                    await viewModel.loadPopularMovies()
                                } else {
                                    await viewModel.searchMovies()
                                    isSearching = true
                                }
                            }
                        }
                    }
                    Spacer()
                } else {
                    List(isSearching ? viewModel.searchMovies : viewModel.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movieId: movie.id, service: viewModel.service)) {
                            HStack(alignment: .top, spacing: 16) {
                                if let url = movie.posterURL {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 100, height: 150)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 150)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 150)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(movie.title)
                                        .font(.headline)
                                    if let date = movie.releaseDate {
                                        Text("Release: \(date)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    if let vote = movie.voteAverage {
                                        Text(String(format: "Rating: %.1f", vote))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(movie.overview)
                                        .font(.body)
                                        .lineLimit(3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadPopularMovies()
        }
    }
        
}

