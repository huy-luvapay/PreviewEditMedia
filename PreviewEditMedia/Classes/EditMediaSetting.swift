//
//  EditMediaSetting.swift
//  PreviewEditMedia
//
//  Created by Van Trieu Phu Huy on 4/29/21.
//

import UIKit

public enum EditMediaLanguage: Int {
    case en = 1, vi = 2
}



class EditMediaSetting: NSObject {
    
    @objc var identifier: String = "1"
    
    private var _buildVersionCurrentApp: Int = 0
    var buildVersionCurrentApp: Int {
        get {
            if(_buildVersionCurrentApp == 0) {
                if let buildString = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String, let buildVersion = Int(buildString) {
                    _buildVersionCurrentApp = buildVersion
                }
            }
            return _buildVersionCurrentApp
            
        }
    }
    
    @objc var dbVersion: Int = 0
    
    
    @objc var rawLanguageApp: Int = EditMediaLanguage.vi.rawValue
    var languageApp: EditMediaLanguage {
        get {
            return EditMediaLanguage(rawValue: rawLanguageApp) ?? EditMediaLanguage.en
        }
        set {
            rawLanguageApp = newValue.rawValue
        }
    }
    
    
    
    //MARK: Shared Instance
    
    public static let shared: EditMediaSetting = {
       
        let instance = EditMediaSetting()
        if let substring = Locale.preferredLanguages.first?.prefix(2) {
            let language = String(substring).lowercased()
            if(language == "vi") {
                instance.languageApp = EditMediaLanguage.vi
            } else {
                instance.languageApp = EditMediaLanguage.en
            }
            
        }
        if let buildString = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String, let buildVersion = Int(buildString) {
            instance.dbVersion = buildVersion
        }
        return instance
    }()
    
    func loadLocalized() {
        if(EditMediaSetting.shared.languageApp == .vi) {
            Bundle.setEditMediaLanguage("vi")
        } else {
            Bundle.setEditMediaLanguage("en")
        }
    }
    
        

}
