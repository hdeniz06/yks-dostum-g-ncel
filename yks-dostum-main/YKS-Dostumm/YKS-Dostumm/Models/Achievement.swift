import Foundation
import SwiftUI

// Achievement categories
enum AchievementCategory: String, CaseIterable, Identifiable {
    case general = "Genel Kullanım Rozetleri"
    case challenges = "Meydan Okumalar"
    case timeBased = "Süre Bazlı Rozetler"
    case goals = "Hedeflerim Rozetleri"
    case study = "Çalışma Rozetleri"
    case test = "Deneme Sınavı Rozetleri"
    case subject = "Konu Takip Rozetleri"
    case social = "Sosyal Rozetler"
    
    var id: String { self.rawValue }
}

// Achievement model
struct Achievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var category: String
    var iconName: String
    var targetCount: Int
    var currentCount: Int
    var isCompleted: Bool {
        return currentCount >= targetCount
    }
    var progress: Double {
        return min(Double(currentCount) / Double(targetCount), 1.0)
    }
    
    // For display in UI
    var progressText: String {
        return "\(currentCount)/\(targetCount)"
    }
}

// Predefined achievements
extension Achievement {
    static var sampleAchievements: [Achievement] = [
        // Genel Kullanım Rozetleri
        Achievement(
            title: "Hoş Geldin!",
            description: "Uygulamaya ilk kez giriş yap",
            category: AchievementCategory.general.rawValue,
            iconName: "gift",
            targetCount: 1,
            currentCount: 1
        ),
        Achievement(
            title: "Düzenli Çalışan",
            description: "Art arda 7 gün boyunca uygulamayı kullan",
            category: AchievementCategory.general.rawValue,
            iconName: "calendar",
            targetCount: 7,
            currentCount: 3
        ),
        Achievement(
            title: "Bağımlı mı Ne?",
            description: "30 gün boyunca her gün giriş yap",
            category: AchievementCategory.general.rawValue,
            iconName: "flame",
            targetCount: 30,
            currentCount: 12
        ),
        Achievement(
            title: "Sadakat Ustası",
            description: "90 gün boyunca her gün giriş yap",
            category: AchievementCategory.general.rawValue,
            iconName: "medal",
            targetCount: 90,
            currentCount: 0
        ),
        Achievement(
            title: "Profil Tamamlayıcı",
            description: "Profil bilgilerini eksiksiz doldur",
            category: AchievementCategory.general.rawValue,
            iconName: "person.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Geri Bildirimci",
            description: "Uygulama hakkında geri bildirim gönder",
            category: AchievementCategory.general.rawValue,
            iconName: "bubble.left.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Tema Değiştirici",
            description: "Uygulama temasını değiştir",
            category: AchievementCategory.general.rawValue,
            iconName: "paintpalette.fill",
            targetCount: 1,
            currentCount: 0
        ),
        
        // Meydan Okumalar
        Achievement(
            title: "Azmin Zaferi",
            description: "180 gün boyunca her gün giriş yap",
            category: AchievementCategory.challenges.rawValue,
            iconName: "trophy",
            targetCount: 180,
            currentCount: 0
        ),
        Achievement(
            title: "Efsane",
            description: "360 gün boyunca her gün giriş yap",
            category: AchievementCategory.challenges.rawValue,
            iconName: "crown",
            targetCount: 360,
            currentCount: 0
        ),
        Achievement(
            title: "Şekillendiren",
            description: "100 kere hedef ekle",
            category: AchievementCategory.challenges.rawValue,
            iconName: "trophy",
            targetCount: 100,
            currentCount: 0
        ),
        Achievement(
            title: "Gece Kuşu",
            description: "Gece 00:00-04:00 arası 10 kez çalış",
            category: AchievementCategory.challenges.rawValue,
            iconName: "moon.stars.fill",
            targetCount: 10,
            currentCount: 0
        ),
        Achievement(
            title: "Erken Kalkan",
            description: "Sabah 05:00-08:00 arası 15 kez çalış",
            category: AchievementCategory.challenges.rawValue,
            iconName: "sunrise.fill",
            targetCount: 15,
            currentCount: 0
        ),
        Achievement(
            title: "Hafta Sonu Savaşçısı",
            description: "10 haftasonu günü 4 saatten fazla çalış",
            category: AchievementCategory.challenges.rawValue,
            iconName: "figure.boxing",
            targetCount: 10,
            currentCount: 0
        ),
        
        // Süre Bazlı Rozetler
        Achievement(
            title: "Dayanıklılık Ustası",
            description: "Tek seferde 2 saat çalış",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "figure.run",
            targetCount: 2,
            currentCount: 0
        ),
        Achievement(
            title: "Maratoncu",
            description: "Toplam 50 saat çalışma süresine ulaş",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "medal",
            targetCount: 50,
            currentCount: 12
        ),
        Achievement(
            title: "Demir İrade",
            description: "Toplam 100 saat çalışma süresine ulaş",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "medal",
            targetCount: 100,
            currentCount: 0
        ),
        Achievement(
            title: "Çalışma Canavarı",
            description: "Toplam 500 saat çalışma süresine ulaş",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "medal.fill",
            targetCount: 500,
            currentCount: 0
        ),
        Achievement(
            title: "Pomodoro Başlangıç",
            description: "İlk pomodoro seansını tamamla",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "timer",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Pomodoro Uzmanı",
            description: "50 pomodoro seansı tamamla",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "timer.circle.fill",
            targetCount: 50,
            currentCount: 0
        ),
        Achievement(
            title: "Pomodoro Efendisi",
            description: "200 pomodoro seansı tamamla",
            category: AchievementCategory.timeBased.rawValue,
            iconName: "timer.square",
            targetCount: 200,
            currentCount: 0
        ),
        
        // Hedeflerim Rozetleri
        Achievement(
            title: "Hedef Koyucu",
            description: "10 kere hedef ekle",
            category: AchievementCategory.goals.rawValue,
            iconName: "target",
            targetCount: 10,
            currentCount: 3
        ),
        Achievement(
            title: "Planlama Ustası",
            description: "50 kere hedef ekle",
            category: AchievementCategory.goals.rawValue,
            iconName: "calendar",
            targetCount: 50,
            currentCount: 0
        ),
        Achievement(
            title: "Hedef Tamamlayıcı",
            description: "İlk hedefini tamamla",
            category: AchievementCategory.goals.rawValue,
            iconName: "checkmark.circle.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Başarı Makinesi",
            description: "25 hedefi tamamla",
            category: AchievementCategory.goals.rawValue,
            iconName: "checkmark.seal.fill",
            targetCount: 25,
            currentCount: 0
        ),
        Achievement(
            title: "Günlük Planlayıcı",
            description: "30 gün boyunca günlük plan oluştur",
            category: AchievementCategory.goals.rawValue,
            iconName: "calendar.day.timeline.left",
            targetCount: 30,
            currentCount: 0
        ),
        Achievement(
            title: "Haftalık Planlayıcı",
            description: "12 haftalık plan oluştur",
            category: AchievementCategory.goals.rawValue,
            iconName: "calendar.badge.clock",
            targetCount: 12,
            currentCount: 0
        ),
        
        // Çalışma Rozetleri
        Achievement(
            title: "İlk Adım",
            description: "İlk çalışma seansını tamamla",
            category: AchievementCategory.study.rawValue,
            iconName: "book.fill",
            targetCount: 1,
            currentCount: 1
        ),
        Achievement(
            title: "Düzenli Çalışan",
            description: "Bir haftada 5 gün çalış",
            category: AchievementCategory.study.rawValue,
            iconName: "book.closed.fill",
            targetCount: 5,
            currentCount: 3
        ),
        Achievement(
            title: "Çalışma Arkadaşı",
            description: "Bir günde 3 farklı ders çalış",
            category: AchievementCategory.study.rawValue,
            iconName: "books.vertical.fill",
            targetCount: 3,
            currentCount: 0
        ),
        Achievement(
            title: "Çalışma Maratonu",
            description: "Bir günde toplam 8 saat çalış",
            category: AchievementCategory.study.rawValue,
            iconName: "clock.arrow.2.circlepath",
            targetCount: 8,
            currentCount: 0
        ),
        Achievement(
            title: "Gece Çalışanı",
            description: "Gece yarısından sonra 3 saat çalış",
            category: AchievementCategory.study.rawValue,
            iconName: "moon.stars",
            targetCount: 3,
            currentCount: 0
        ),
        Achievement(
            title: "Sabah Kuşu",
            description: "Sabah 6'dan önce çalışmaya başla",
            category: AchievementCategory.study.rawValue,
            iconName: "sunrise",
            targetCount: 1,
            currentCount: 0
        ),
        
        // Deneme Sınavı Rozetleri
        Achievement(
            title: "İlk Deneme",
            description: "İlk deneme sınavı sonucunu kaydet",
            category: AchievementCategory.test.rawValue,
            iconName: "doc.text.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Deneme Takipçisi",
            description: "10 deneme sınavı sonucunu kaydet",
            category: AchievementCategory.test.rawValue,
            iconName: "doc.on.doc.fill",
            targetCount: 10,
            currentCount: 0
        ),
        Achievement(
            title: "Deneme Uzmanı",
            description: "30 deneme sınavı sonucunu kaydet",
            category: AchievementCategory.test.rawValue,
            iconName: "doc.on.clipboard.fill",
            targetCount: 30,
            currentCount: 0
        ),
        Achievement(
            title: "İlerleme Kaydeden",
            description: "Deneme sınavı netlerini 5 kez artır",
            category: AchievementCategory.test.rawValue,
            iconName: "chart.line.uptrend.xyaxis",
            targetCount: 5,
            currentCount: 0
        ),
        Achievement(
            title: "Analiz Uzmanı",
            description: "20 deneme sınavı analizi yap",
            category: AchievementCategory.test.rawValue,
            iconName: "chart.bar.xaxis",
            targetCount: 20,
            currentCount: 0
        ),
        Achievement(
            title: "Yanlış Avcısı",
            description: "100 yanlış soruyu analiz et",
            category: AchievementCategory.test.rawValue,
            iconName: "xmark.circle.fill",
            targetCount: 100,
            currentCount: 0
        ),
        
        // Konu Takip Rozetleri
        Achievement(
            title: "Konu Takipçisi",
            description: "İlk konuyu tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "list.bullet.clipboard",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Ders Tamamlayıcı",
            description: "Bir dersin tüm konularını tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "checkmark.square.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Matematik Ustası",
            description: "Tüm matematik konularını tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "function",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Türkçe Ustası",
            description: "Tüm Türkçe konularını tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "text.book.closed.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Fen Bilimleri Ustası",
            description: "Tüm Fen Bilimleri konularını tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "atom",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Sosyal Bilimler Ustası",
            description: "Tüm Sosyal Bilimler konularını tamamla",
            category: AchievementCategory.subject.rawValue,
            iconName: "globe",
            targetCount: 1,
            currentCount: 0
        ),
        
        // Sosyal Rozetler
        Achievement(
            title: "Arkadaş Davet Eden",
            description: "Bir arkadaşını uygulamaya davet et",
            category: AchievementCategory.social.rawValue,
            iconName: "person.2.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Sosyal Çalışan",
            description: "Çalışma arkadaşı bul ve birlikte çalış",
            category: AchievementCategory.social.rawValue,
            iconName: "person.3.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Paylaşımcı",
            description: "Çalışma istatistiklerini sosyal medyada paylaş",
            category: AchievementCategory.social.rawValue,
            iconName: "square.and.arrow.up.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Topluluk Üyesi",
            description: "YKS Dostum topluluğuna katıl",
            category: AchievementCategory.social.rawValue,
            iconName: "person.3.sequence.fill",
            targetCount: 1,
            currentCount: 0
        ),
        Achievement(
            title: "Yardımsever",
            description: "Toplulukta 5 soruya cevap ver",
            category: AchievementCategory.social.rawValue,
            iconName: "hand.raised.fill",
            targetCount: 5,
            currentCount: 0
        ),
        Achievement(
            title: "Motivasyon Kaynağı",
            description: "10 motivasyon mesajı paylaş",
            category: AchievementCategory.social.rawValue,
            iconName: "heart.fill",
            targetCount: 10,
            currentCount: 0
        )
    ]
}
