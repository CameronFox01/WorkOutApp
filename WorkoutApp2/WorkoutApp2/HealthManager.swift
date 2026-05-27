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
    @Published var lastFiveDaysActiveCalories: [(date: Date, calories: Int)] = []
    
    let healthStore = HKHealthStore()
    
    @Published var steps: Int = 0  // ✅ Add this published property
    @Published var distance: Double = 0
    @Published var activeCalories: Double = 0
    @Published var flightsClimbed: Int = 0
    
    init(){
        let steps = HKQuantityType(.stepCount)
        let distance = HKQuantityType(.distanceWalkingRunning)
        let activeEnergy = HKQuantityType(.activeEnergyBurned)
        let flights = HKQuantityType(.flightsClimbed)

        let healthTypes: Set = [
            steps,
            distance,
            activeEnergy,
            flights
        ]
        
        Task{
            do{
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("error fetching health data")
            }
        }
    }
    
    func fetchFlightsClimbed() {
        let flightsType = HKQuantityType(.flightsClimbed)

        let startOfDay = Calendar.current.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: flightsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in

            guard let quantity = result?.sumQuantity(),
                  error == nil else {
                print("Error fetching flights climbed")
                return
            }

            let sumCount = Int(quantity.doubleValue(for: .count()))

            DispatchQueue.main.async {
                self.flightsClimbed = sumCount
            }
        }

        healthStore.execute(query)
    }
    
    func fetchSteps() {
        let steps = HKQuantityType(.stepCount)
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
          
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
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
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
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
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let isToday = dayOffset == 0
            let endOfDay = isToday ? Date() : (calendar.date(byAdding: .day, value: 1, to: day) ?? day)

            let predicate = HKQuery.predicateForSamples(
                withStart: day,
                end: endOfDay,
                options: .strictStartDate
            )

            group.enter()
            
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in

                let count = Int(
                    result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                )

                results.append((date: day, steps: count))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.lastFiveDaysSteps = results.sorted { $0.date < $1.date }
        }
    }
    
    func fetchLastFiveDaysActiveCalories() {
        let calorieType = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var results: [(date: Date, calories: Int)] = []
        let group = DispatchGroup()

        for dayOffset in (0..<5).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let isToday = dayOffset == 0
            let endOfDay = isToday ? Date() : (calendar.date(byAdding: .day, value: 1, to: day) ?? day)

            let predicate = HKQuery.predicateForSamples(withStart: day, end: endOfDay)

            group.enter()
            let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let kcal = Int(result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
                results.append((date: day, calories: kcal))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.lastFiveDaysActiveCalories = results.sorted { $0.date < $1.date }
        }
    }
    
    func fetchActiveCalories() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            guard let quantity = result?.sumQuantity() else { return }

            let calories = quantity.doubleValue(for: .kilocalorie())

            DispatchQueue.main.async {
                self.activeCalories = calories
            }
        }

        healthStore.execute(query)
    }
}

