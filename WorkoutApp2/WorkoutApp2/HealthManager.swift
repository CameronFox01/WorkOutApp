//
//  HealthManager.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/15/26.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var steps: Int = 0  // ✅ Add this published property
    @Published var distance: Double = 0
    
    init(){
        let steps = HKQuantityType(.stepCount)
        let distance = HKQuantityType(.distanceWalkingRunning)
        
        let healthTypes: Set = [steps, distance]
        
        Task{
            do{
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("error fetching health data")
            }
        }
    }
    
    func fetchSteps() {
        let steps = HKQuantityType(.stepCount)
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
          
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching steps for today")
                return
            }
            
            let sumCount = Int(quantity.doubleValue(for: .count()))
            
            DispatchQueue.main.async {  // ✅ Always update UI on main thread
                self.steps = sumCount
            }
        }
        
        healthStore.execute(query)
    }
    
    // Code for fetching Distance
    func fetchDistance() {
        let distance = HKQuantityType(.distanceWalkingRunning)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching distance for today")
                return
            }
            DispatchQueue.main.async {
                self.distance = quantity.doubleValue(for: .meter())  // ✅ Always store as meters
            }
        }
        healthStore.execute(query)
    }
}
