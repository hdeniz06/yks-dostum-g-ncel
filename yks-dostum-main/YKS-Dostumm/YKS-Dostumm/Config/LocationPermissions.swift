import Foundation

// Bu dosya, Info.plist'e eklenmesi gereken konum izinlerini tanımlar
// Xcode bu değerleri otomatik olarak Info.plist'e ekleyecektir

// Konum izinleri için gerekli açıklamalar:
// NSLocationWhenInUseUsageDescription - Uygulama açıkken konum kullanımı için
// NSLocationAlwaysAndWhenInUseUsageDescription - Uygulama arka planda çalışırken konum kullanımı için

// Proje ayarlarında bu izinleri eklemek için:
// 1. Xcode'da projenizi seçin
// 2. "Info" sekmesine tıklayın
// 3. "Custom iOS Target Properties" bölümüne aşağıdaki anahtarları ekleyin:
// - NSLocationWhenInUseUsageDescription: Yakınındaki kütüphaneleri ve çalışma alanlarını görebilmek için konum izni gereklidir.
// - NSLocationAlwaysAndWhenInUseUsageDescription: Yakınındaki kütüphaneleri ve çalışma alanlarını görebilmek için konum izni gereklidir.
