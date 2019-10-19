import Foundation

extension DateFormatter {
    static var cachedFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    } ()
    
    static func getLocalizedDate(oldDate: String) -> String? {
        let date = DateFormatter.cachedFormatter.date(from: oldDate)
        guard let convertedDate = date else { return nil }
        return DateFormatter.localizedString(from: convertedDate, dateStyle: .short, timeStyle: .none)
    }
}
