import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    private func dismissKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    // Add tap gesture to dismiss keyboard
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissKeyboard()
                        }
                    
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isTyping {
                            HStack(alignment: .bottom, spacing: 2) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                
                                Text("YKS Asistanı yazıyor...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 8)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { oldValue, newValue in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isTyping) { oldValue, newValue in
                    withAnimation {
                        scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Input Bar
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 15) {
                    // Text Input Field
                    ZStack {
                        TextField("Bir soru sor...", text: $viewModel.inputText)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .focused($isInputFocused)
                            .submitLabel(.send)
                            .autocapitalization(.sentences)
                            .disableAutocorrection(false)
                            .onSubmit {
                                if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isTyping {
                                    viewModel.sendMessage()
                                }
                            }
                    }
                    .frame(minHeight: 44)
                    
                    // Send Button
                    Button(action: {
                        viewModel.sendMessage()
                        dismissKeyboard()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("YKS Asistanı")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.sender == .assistant {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 5) {
                Text(message.content)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.sender == .user ? Color.blue : Color(UIColor.secondarySystemBackground))
                    )
                    .foregroundColor(message.sender == .user ? .white : .primary)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.sender == .user {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
}
