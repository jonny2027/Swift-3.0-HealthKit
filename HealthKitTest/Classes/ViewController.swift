//
//  ViewController.swift
//  HealthKitTest
//
//  Created by Jonathan Dixon on 28/06/2016.
//  Copyright © 2016 Jonathan Dixon. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class ViewController: UIViewController
{

    @IBOutlet weak var stepCountLabel: UILabel!
    
    let healthKitStore = HKHealthStore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(checkAuthorization())
        {
            if(HKHealthStore.isHealthDataAvailable())
            {
                recentSteps() { steps, error in
                    DispatchQueue.main.async {
                        self.stepCountLabel.text = String(format:"%.0f", steps)
                    }
                }
            }
        }
    }
    
    func updateStepCount()
    {
        
    }

    func checkAuthorization() -> Bool
    {
        var isEnabled = true

        if HKHealthStore.isHealthDataAvailable()
        {
            let healthKitTypesToRead : Set = [
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                HKObjectType.quantityType(forIdentifier:HKQuantityTypeIdentifier.stepCount)!,
                HKObjectType.workoutType()
            ]
            
            healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead, completion: { (success, error) in
                isEnabled = success
            })
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func recentSteps(completion: (Double, NSError?) -> () )
    {
        let healthKitTypesToRead = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)


        let calendar = Calendar.current()
        let yesterday = calendar.date(byAdding: Calendar.Unit.hour, value: -15, to: Date(), options: [])
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: Date(), options: [])

        let query = HKSampleQuery(sampleType: healthKitTypesToRead!, predicate: predicate, limit: 0, sortDescriptors: nil) { query, results, error in
            var steps: Double = 0
            
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    if(result.device?.model != "iPhone")
                    {
                        steps += result.quantity.doubleValue(for: HKUnit.count())
                    }
                }
            }
            
            completion(steps, error)
        }
        
        healthKitStore.execute(query)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

