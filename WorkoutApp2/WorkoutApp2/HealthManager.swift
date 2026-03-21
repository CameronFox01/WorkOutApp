//
//  HealthManager.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/15/26.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    // In HealthManager
    @Published var lastFiveDaysSteps: [(date: Date, steps: Int)] = []
    
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

    func fetchLastFiveDaysSteps() {
        let stepsType = HKQuantityType(.stepCount)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var results: [(date: Date, steps: Int)] = []
        let group = DispatchGroup()

        for dayOffset in (0..<5).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today),
                  let endOfDay = calendar.date(byAdding: .day, value: 1, to: day) else { continue }

            let predicate = HKQuery.predicateForSamples(withStart: day, end: endOfDay, options: .strictStartDate)

            group.enter()
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate) { _, result, _ in
                let count = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                results.append((date: day, steps: count))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            // Sort by date since queries may return out of order
            self.lastFiveDaysSteps = results.sorted { $0.date < $1.date }
        }
    }
}
