//
//  DataConsumptionInteractor.swift
//  VIP-Clean-Architecture
//
//  Created by Ahil Ahilendran on 5/8/20.
//  Copyright © 2020 Ahil Ahilendran. All rights reserved.
//

import Foundation
import Alamofire

final class DataConsumptionInteractor {
    
    let output: DataConsumptionPresenterInput
    let apiWorker: DataConsumptionApiWorker = DataConsumptionApiWorker()
    
    private var dataConsumptionRecord = [[SPHDataResponse.Record]]()
    var offset: Int = .zero
    var limit: Int = SPHConstants.limit
    var isFetchInProgress = false
    
    // MARK: - Initializers
    init(output: DataConsumptionPresenterInput) {
        self.output = output
        apiWorker.apiDelegate = self
    }
}

extension DataConsumptionInteractor: DataConsumptionInteractorInput {
    func getMobileDataConsumption() {
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        apiWorker.getDataConsumption(offset: offset, resourceId: Environment.resourceId, limit: limit)
    }
}

extension  DataConsumptionInteractor: DataConsumptionApiProtocol {
    func didGetDataConsumption(response: SPHDataResponse.DataUsage?) {
        self.isFetchInProgress = false
        self.offset = response?.result?.offset ?? .zero
        self.limit = response?.result?.limit ?? SPHConstants.limit
        updateConsumptionList(response?.result?.records ?? [])
    }
    
    func didFailedDataConsumption() {
        self.isFetchInProgress = false
        self.output.displayErrorMessage(message: SPHL.tryAgain.localized)
        
    }
}

extension DataConsumptionInteractor {
    func updateConsumptionList(_ records: [SPHDataResponse.Record]) {
        var oldRecord = self.dataConsumptionRecord.flatMap{$0}
        oldRecord = oldRecord + records
        
        let groupedRecordByYear = oldRecord.group { $0.year }
        self.dataConsumptionRecord = groupedRecordByYear
        
        self.offset = self.offset + self.limit
        self.output.presentData(data: dataConsumptionRecord)
    }
}
