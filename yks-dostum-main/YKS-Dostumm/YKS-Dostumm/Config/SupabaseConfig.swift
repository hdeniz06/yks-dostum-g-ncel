import Foundation

enum SupabaseConfig {
    // MARK: - Supabase Configuration
    static let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://bqvjtmzqmgxoerchskex.supabase.co"
    static let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_API_KEY"] ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxdmp0bXpxbWd4b2VyY2hza2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ4MTM3MTcsImV4cCI6MjA2MDM4OTcxN30.5SC12GdHDt9pK7M21gTwrojHJZM3loznGl1wU43Hlqo"
}
