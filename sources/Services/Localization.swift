//
//  Localization.swift
//  Fatx007 (Fatx007)
//
//  Reconstructed LanguageStore & multi-language localization dictionary.
//

import SwiftUI
import Combine

public enum FFLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case indonesian = "id"
    case vietnamese = "vi"
    case portuguese = "pt"
    case moroccan = "ma"
    case arabic = "ar"
    case taiwanese = "zh_TW"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .indonesian: return "Bahasa Indonesia"
        case .vietnamese: return "Tiếng Việt"
        case .portuguese: return "Português"
        case .moroccan: return "Darija (Moroccan)"
        case .arabic: return "العربية"
        case .taiwanese: return "繁體中文"
        }
    }
}

public class LanguageStore: ObservableObject {
    public static let shared = LanguageStore()
    
    private let defaultsKey = "ffxc.language"
    
    @Published public var current: FFLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: defaultsKey)
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: defaultsKey),
           let lang = FFLanguage(rawValue: saved) {
            self.current = lang
        } else {
            self.current = .english
        }
    }
    
    public func string(for key: String) -> String {
        if let table = Self.translations[current], let val = table[key] {
            return val
        }
        return Self.translations[.english]?[key] ?? key
    }
    
    // MARK: - Translation Tables (Extracted from Mach-O binary)
    private static let translations: [FFLanguage: [String: String]] = [
        .english: [
            "select_language": "Select Language",
            "continue": "Continue",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "VALIDATE",
            "validating": "Validating...",
            "key_invalid": "Invalid or expired key. Please check and try again.",
            "logout": "Logout",
            "cancel": "Cancel",
            "device": "Device",
            "ios_version": "iOS Version",
            "expires": "Expires In",
            "verified": "VERIFIED",
            "status_online": "STATUS : ONLINE",
            "status_offline": "STATUS : OFFLINE",
            "inject": "INJECT",
            "uninject": "UNINJECT",
            "unavailable": "UNAVAILABLE",
            "injecting": "Injecting...",
            "inject_success": "Injection complete. Launching game.",
            "inject_failed": "Injection failed.",
            "supported": "Supported",
            "not_supported": "Not Supported",
            "checking": "Checking...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "ESP Color",
            "esp_thickness": "Line Thickness",
            "aim_fov_mode": "Aim FOV Mode",
            "aim_target": "Aim Target",
            "headshot_rate": "Headshot Rate",
            "fov_radius": "FOV Radius",
            "fast_reload": "Fast Reload",
            "fast_fire": "Fast Fire Rate",
            "reset_settings": "Reset selected game settings"
        ],
        .vietnamese: [
            "select_language": "Chọn Ngôn Ngữ",
            "continue": "Tiếp Tục",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "XÁC NHẬN",
            "validating": "Đang kiểm tra...",
            "key_invalid": "Khóa không hợp lệ hoặc đã hết hạn.",
            "logout": "Đăng Xuất",
            "cancel": "Hủy",
            "device": "Thiết Bị",
            "ios_version": "Phiên Bản iOS",
            "expires": "Hết Hạn Trong",
            "verified": "ĐÃ XÁC THỰC",
            "status_online": "TRẠNG THÁI : TRỰC TUYẾN",
            "status_offline": "TRẠNG THÁI : NGOẠI TUYẾN",
            "inject": "TIÊM HACK",
            "uninject": "GỠ TIÊM",
            "unavailable": "KHÔNG KHẢ DỤNG",
            "injecting": "Đang tiêm...",
            "inject_success": "Tiêm thành công. Đang mở game.",
            "inject_failed": "Tiêm thất bại.",
            "supported": "Được hỗ trợ",
            "not_supported": "Không hỗ trợ",
            "checking": "Đang kiểm tra...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "Màu ESP",
            "esp_thickness": "Độ dày nét",
            "aim_fov_mode": "Chế độ Aim FOV",
            "aim_target": "Mục tiêu Aim",
            "headshot_rate": "Tỉ lệ Headshot",
            "fov_radius": "Bán kính FOV",
            "fast_reload": "Nạp đạn nhanh",
            "fast_fire": "Bắn nhanh",
            "reset_settings": "Đặt lại cài đặt game"
        ],
        .indonesian: [
            "select_language": "Pilih Bahasa",
            "continue": "Lanjut",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "VALIDASI",
            "validating": "Memvalidasi...",
            "key_invalid": "Kunci tidak valid atau kedaluwarsa.",
            "logout": "Keluar",
            "cancel": "Batal",
            "device": "Perangkat",
            "ios_version": "Versi iOS",
            "expires": "Berakhir Dalam",
            "verified": "TERVERIFIKASI",
            "status_online": "STATUS : ONLINE",
            "status_offline": "STATUS : OFFLINE",
            "inject": "INJEK",
            "uninject": "HAPUS INJEKSI",
            "unavailable": "TIDAK TERSEDIA",
            "injecting": "Menginjeksi...",
            "inject_success": "Injeksi selesai. Membuka game.",
            "inject_failed": "Injeksi gagal.",
            "supported": "Didukung",
            "not_supported": "Tidak Didukung",
            "checking": "Memeriksa...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "Warna ESP",
            "esp_thickness": "Ketebalan Garis",
            "aim_fov_mode": "Mode Aim FOV",
            "aim_target": "Target Aim",
            "headshot_rate": "Tingkat Headshot",
            "fov_radius": "Radius FOV",
            "fast_reload": "Isi Ulang Cepat",
            "fast_fire": "Tembak Cepat",
            "reset_settings": "Atur ulang pengaturan game"
        ],
        .portuguese: [
            "select_language": "Selecionar Idioma",
            "continue": "Continuar",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "VALIDAR",
            "validating": "Validando...",
            "key_invalid": "Chave inválida ou expirada.",
            "logout": "Sair",
            "cancel": "Cancelar",
            "device": "Dispositivo",
            "ios_version": "Versão do iOS",
            "expires": "Expira Em",
            "verified": "VERIFICADO",
            "status_online": "STATUS : ONLINE",
            "status_offline": "STATUS : OFFLINE",
            "inject": "INJETAR",
            "uninject": "DESINJETAR",
            "unavailable": "INDISPONÍVEL",
            "injecting": "Injetando...",
            "inject_success": "Injeção concluída. Abrindo jogo.",
            "inject_failed": "Falha na injeção.",
            "supported": "Suportado",
            "not_supported": "Não Suportado",
            "checking": "Verificando...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "Cor do ESP",
            "esp_thickness": "Espessura da Linha",
            "aim_fov_mode": "Modo Aim FOV",
            "aim_target": "Alvo do Aim",
            "headshot_rate": "Taxa de Headshot",
            "fov_radius": "Raio do FOV",
            "fast_reload": "Recarga Rápida",
            "fast_fire": "Disparo Rápido",
            "reset_settings": "Redefinir configurações do jogo"
        ],
        .arabic: [
            "select_language": "اختر اللغة",
            "continue": "متابعة",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "تفعيل",
            "validating": "جاري التحقق...",
            "key_invalid": "المفتاح غير صالح أو منتهي الصلاحية.",
            "logout": "تسجيل خروج",
            "cancel": "إلغاء",
            "device": "الجهاز",
            "ios_version": "إصدار iOS",
            "expires": "ينتهي في",
            "verified": "تم التحقق",
            "status_online": "الحالة : متصل",
            "status_offline": "الحالة : غير متصل",
            "inject": "حقن",
            "uninject": "إلغاء الحقن",
            "unavailable": "غير متاح",
            "injecting": "جاري الحقن...",
            "inject_success": "اكتمل الحقن. جاري فتح اللعبة.",
            "inject_failed": "فشل الحقن.",
            "supported": "مدعوم",
            "not_supported": "غير مدعوم",
            "checking": "جاري الفحص...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "لون ESP",
            "esp_thickness": "سماكة الخط",
            "aim_fov_mode": "وضع مجال الرؤية",
            "aim_target": "هدف التصويب",
            "headshot_rate": "نسبة إصابة الرأس",
            "fov_radius": "نصف قطر الرؤية",
            "fast_reload": "إعادة تلقيم سريعة",
            "fast_fire": "إطلاق نار سريع",
            "reset_settings": "إعادة ضبط الإعدادات"
        ],
        .moroccan: [
            "select_language": "Khtar Lora",
            "continue": "Zid",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "VALIDE",
            "validating": "Kanchekkiw...",
            "key_invalid": "Sarot ralat ola salat.",
            "logout": "Khoroj",
            "cancel": "Anuler",
            "device": "Appareil",
            "ios_version": "Version iOS",
            "expires": "Katsala f",
            "verified": "MVERIFIY",
            "status_online": "STATUT : CONNECTE",
            "status_offline": "STATUT : HORS LIGNE",
            "inject": "INJECTER",
            "uninject": "DESINJECTER",
            "unavailable": "MAKHEDDAMCH",
            "injecting": "Kanjectiw...",
            "inject_success": "Injecta naja7. Khelli lgame t7el.",
            "inject_failed": "Injection khasrat.",
            "supported": "Supporte",
            "not_supported": "Ma supportech",
            "checking": "Kanverifiw...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "Kholor ESP",
            "esp_thickness": "Rold dyal khat",
            "aim_fov_mode": "Mode Aim FOV",
            "aim_target": "Cible Aim",
            "headshot_rate": "Poucentage Headshot",
            "fov_radius": "Rayon FOV",
            "fast_reload": "T3mar d rrasas bzerba",
            "fast_fire": "Tir bzerba",
            "reset_settings": "Rje3 réglage d lgame"
        ],
        .taiwanese: [
            "select_language": "選擇語言",
            "continue": "繼續",
            "app_name": "Fatx007",
            "key_placeholder": "FFXC-XXXX-XXXXX",
            "validate": "驗證金鑰",
            "validating": "驗證中...",
            "key_invalid": "金鑰無效或已過期。",
            "logout": "登出",
            "cancel": "取消",
            "device": "設備型號",
            "ios_version": "iOS 版本",
            "expires": "剩餘時間",
            "verified": "已認證",
            "status_online": "狀態：在線",
            "status_offline": "狀態：離線",
            "inject": "注入功能",
            "uninject": "解除注入",
            "unavailable": "無法使用",
            "injecting": "注入中...",
            "inject_success": "注入完成，正在啟動遊戲。",
            "inject_failed": "注入失敗。",
            "supported": "已支援",
            "not_supported": "不支援",
            "checking": "檢查環境中...",
            "game_ff": "Free Fire",
            "game_ffmax": "Free Fire MAX",
            "esp_color": "透視顏色",
            "esp_thickness": "線條粗細",
            "aim_fov_mode": "自瞄範圍模式",
            "aim_target": "自瞄部位",
            "headshot_rate": "爆頭機率",
            "fov_radius": "自瞄範圍半徑",
            "fast_reload": "快速換彈",
            "fast_fire": "快速射擊",
            "reset_settings": "重置遊戲設定"
        ]
    ]
}
