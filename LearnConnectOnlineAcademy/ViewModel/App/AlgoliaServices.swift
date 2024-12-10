//
//  AlgoliaServices.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import Foundation
import AlgoliaSearchClient

class AlgoliaService{
    
    static let shared = AlgoliaService()//tek sınıf örneği
    
    let client = SearchClient(appID: ApplicationID(stringLiteral: AlgoliaConstants().kALGOLIA_APP_ID),
                              apiKey: APIKey(stringLiteral: AlgoliaConstants().kALGOLIA_ADMIN_KEY))
    let index = SearchClient(appID: ApplicationID(stringLiteral: AlgoliaConstants().kALGOLIA_APP_ID),
                             apiKey: APIKey(stringLiteral: AlgoliaConstants().kALGOLIA_ADMIN_KEY)).index(withName: "item_Name")
    
    private init(){
    }
    
    
    
}
