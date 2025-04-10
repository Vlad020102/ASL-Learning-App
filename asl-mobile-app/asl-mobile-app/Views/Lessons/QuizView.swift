import SwiftUI
import AVKit

class QuizViewModel: ObservableObject {
    @Published var quizes: QuizData = .init(bubblesQuizes: [], matchingQuizes: [], alphabetQuizes: [])
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadQuizes() {
        NetworkService.shared.getQuiz() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.quizes = response.quizes
                case .failure(let error):
                    self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct QuizCatalogueView: View {
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                AppColors.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, retryAction:{
                            AuthManager.shared.removeToken()
                        })
                    } else {
                        List {
                            ForEach(viewModel.quizes.bubblesQuizes, id: \.id) { quiz in
                                bubblesCardView(for: quiz)
                            }
                            .listRowBackground(AppColors.background)
                            ForEach(viewModel.quizes.matchingQuizes, id: \.id) { quiz in
                                matchingCardView(for: quiz)
                            }
                            .listRowBackground(AppColors.background)
                            ForEach(viewModel.quizes.alphabetQuizes, id: \.id) { quiz in alphabetCardView(for: quiz)}
                            .listRowBackground(AppColors.background)
                            
                        }
                        .onAppear {
                            viewModel.loadQuizes()
                        }
                        .listStyle(PlainListStyle())
                        .background(AppColors.background)
                    }
                }
                .navigationTitle("Quizes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .foregroundStyle(AppColors.textSecondary)
            }
            .accentColor(AppColors.card) // Sets navigation link and button colors
        }
    }
    
    @ViewBuilder
    private func bubblesCardView(for bubblesQuiz: BubblesQuizData) -> some View {
        if bubblesQuiz.status.toString() == "Locked" {
            BubblesQuizCard(bubblesQuiz: bubblesQuiz)
                .opacity(0.6)
        } else if bubblesQuiz.status.toString() == "InProgress" {
            BubblesQuizCard(bubblesQuiz: bubblesQuiz)
        } else if bubblesQuiz.status.toString() == "Completed" {
            BubblesQuizCard(bubblesQuiz: bubblesQuiz)
                .opacity(0.6)
        } else if bubblesQuiz.status.toString() == "Failed" {
            BubblesQuizCard(bubblesQuiz: bubblesQuiz)
                .opacity(0.6)
        }
    }
    
    @ViewBuilder
    private func matchingCardView(for matchingQuiz: MatchingQuizData) -> some View {
        if matchingQuiz.status.toString() == "Locked" {
            MatchingQuizCard(matchingQuiz: matchingQuiz)
                .opacity(0.6)
        } else if matchingQuiz.status.toString() == "InProgress" {
            MatchingQuizCard(matchingQuiz: matchingQuiz)
        } else if matchingQuiz.status.toString() == "Completed" {
            MatchingQuizCard(matchingQuiz: matchingQuiz)
                .opacity(0.6)
        } else if matchingQuiz.status.toString() == "Failed" {
            MatchingQuizCard(matchingQuiz: matchingQuiz)
                .opacity(0.6)
        }
    }
    
    @ViewBuilder
    private func alphabetCardView(for alphabetQuiz: AlphabetQuizData) -> some View {
        if alphabetQuiz.status.toString() == "Locked" {
            AlphabetQuizCard(alphabetQuiz: alphabetQuiz)
                .opacity(0.6)
        } else if alphabetQuiz.status.toString() == "InProgress" {
            AlphabetQuizCard(alphabetQuiz: alphabetQuiz)
        } else if alphabetQuiz.status.toString() == "Completed" {
            AlphabetQuizCard(alphabetQuiz: alphabetQuiz)
                .opacity(0.6)
        } else if alphabetQuiz.status.toString() == "Failed" {
            AlphabetQuizCard(alphabetQuiz: alphabetQuiz)
                .opacity(0.6)
        }
    }
    struct AlphabetQuizCard: View {
        let alphabetQuiz: AlphabetQuizData
        var body: some View {
            
            NavigationLink(destination: AlphabetExerciseView(
                testStrings: alphabetQuiz.signs?.map { $0.text} ?? ["A", "B", "C", "D", "E"],
                quizID: alphabetQuiz.id,
                startSign: alphabetQuiz.signs?.first?.text ?? "A"
                )) {
                GenericQuizCard(
                    title: alphabetQuiz.title,
                    type: alphabetQuiz.type,
                    status: alphabetQuiz.status,
                    score: alphabetQuiz.score,
                    livesRemaining: alphabetQuiz.livesRemaining
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(alphabetQuiz.status.toString() == "Locked" ||
                      alphabetQuiz.status.toString() == "Failed" ||
                      alphabetQuiz.status.toString() == "Completed")
        }
    }
    struct BubblesQuizCard: View {
        let bubblesQuiz: BubblesQuizData
        
        var body: some View {
            NavigationLink(destination: BubblesView(quiz: bubblesQuiz)) {
                GenericQuizCard(
                    title: bubblesQuiz.title,
                    type: bubblesQuiz.type,
                    status: bubblesQuiz.status,
                    score: bubblesQuiz.score,
                    livesRemaining: bubblesQuiz.livesRemaining
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(bubblesQuiz.status.toString() == "Locked" ||
                      bubblesQuiz.status.toString() == "Failed" ||
                      bubblesQuiz.status.toString() == "Completed")
        }
    }
    
    struct MatchingQuizCard: View {
        let matchingQuiz: MatchingQuizData
        
        var body: some View {
            NavigationLink(destination: MatchingView(exercise: matchingQuiz)) {
                GenericQuizCard(
                    title: matchingQuiz.title,
                    type: matchingQuiz.type,
                    status: matchingQuiz.status,
                    score: matchingQuiz.score,
                    livesRemaining: matchingQuiz.livesRemaining
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(matchingQuiz.status.toString() == "Locked" ||
                      matchingQuiz.status.toString() == "Failed" ||
                      matchingQuiz.status.toString() == "Completed")
        }
    }
    
    struct QuizContainerView_Previews: PreviewProvider {
        static var previews: some View {
            QuizCatalogueView()
        }
    }
}
