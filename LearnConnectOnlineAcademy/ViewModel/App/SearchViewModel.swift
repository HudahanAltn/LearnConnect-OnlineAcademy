//
//  SearchViewModel.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import Foundation
import AlgoliaSearchClient

class SearchViewModel{
    
    //algolia'da item ara
    func searchItemAtAlgolia(searchString:String)->[String]{

        let index = AlgoliaService.shared.index

        let query = Query(stringLiteral: searchString)

        var  itemObjectIdResult:[String] = [String]()
        
        do{
            let results = try index.search(query: query)
            
            itemObjectIdResult.removeAll()
            
            for sonuc in results.hits{

                itemObjectIdResult.append("\(sonuc.objectID)")
            }

        }catch{

            print("aloglia arama hatası.Hatakodu:\(error.localizedDescription)")
        }

        return itemObjectIdResult
    }
}
