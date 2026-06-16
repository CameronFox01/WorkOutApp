//
//  HealthManager.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 3/15/26.
//

import Foundation
import HealthKit
import SwiftUI

class HealthManager: ObservableObject {
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    
    // In HealthManager
    @Published var lastFiveDaysSteps: [(date: Date, steps: Int)] = []
    @Published var lastFiveDaysActiveCalories: [(date: Date, calories: Int)] = []
    
    let healthStore = HKHealthStore()
    
    @Published var steps: Int = 0 
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
    
    // Calories Section
    var fiveDayAverageCalories: Int {

        let total = lastFiveDaysCalories.reduce(0) {
            $0 + $1.calories
        }

        return lastFiveDaysCalories.isEmpty
        ? 0
        : total / lastFiveDaysCalories.count
    }
    
    var lastFiveDaysCalories: [(date: Date, calories: Int)] {

        lastFiveDaysSteps.map { stepDay in

            let healthCalories =
                lastFiveDaysActiveCalories.first {
                    Calendar.current.isDate(
                        $0.date,
                        inSameDayAs: stepDay.date
                    )
                }?.calories ?? 0

            return (
                date: stepDay.date,
                calories: healthCalories > 0
                    ? healthCalories
                    : Int(Double(stepDay.steps) * 0.04)
            )
        }
    }
    
    func caloriesForDay(steps: Int, healthKitCalories: Double?) -> Int {
        if let hk = healthKitCalories, hk > 0 {
            return Int(hk)
        } else {
            return Int(Double(steps) * 0.04)
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
    
    // Steps/Distance Section
    var getLastFiveDaysSteps: [(date: Date, steps: Int)] {
        lastFiveDaysSteps
    }

    var fiveDayAverageSteps: Int {

        let total = getLastFiveDaysSteps.reduce(0) { $0 + $1.steps }

        return getLastFiveDaysSteps.isEmpty
        ? 0
        : total / getLastFiveDaysSteps.count
    }
    
    var unitSystem: UnitSystem {
        get {
            UnitSystem(rawValue: unitSystemRaw) ?? .metric
        }
        set {
            unitSystemRaw = newValue.rawValue
        }
    }
    
     var formattedDistance: String {

        if unitSystem == .metric {

            let km = distance / 1000

            return String(format: "%.2f km", km)

        } else {

            let miles = distance / 1609.34

            return String(format: "%.2f mi", miles)
        }
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

