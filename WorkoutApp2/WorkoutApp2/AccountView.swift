//
//  AccountView.swift
//  WorkoutApp2
//
//  Created by Cameron Fox on 6/4/25.
//

// TODO: This needs to be have a design that is nice to see. This is ugly/boring.
import SwiftUI

struct AccountView: View {
    @AppStorage("userName") private var name: String = ""
    @AppStorage("unitSystem") private var unitSystemRaw: String = UnitSystem.metric.rawValue
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userWeight") private var weight: String = ""
    @AppStorage("userBirthday") private var birthday = Date()
    @AppStorage("userGender") private var genderRaw: String = Gender.male.rawValue
    
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = true
    
    
    
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Name")) {
                    Text(name)
                }
                
                Section(header: Text("Body Info")){
                    Text(displayHeight)
                    
                    Text(weight + " " + weightUnit)
                    
                }
                Section(header: Text("Birthday")) {
                    Text("\(birthday, style: .date)")
                }
                
                Section(header: Text("Gender")) {
                    Text(genderRaw)
                }
                
                Section(header: Text("Unit System")){
                    Text(unitSystemRaw)
                }
                
                Button("Reset App Setup") {
                    hasCompletedSetup = false
                }
            }
            .navigationTitle("Account")
            
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(destination: GoalView()){
                        Image(systemName: "trophy.circle")
                            .font(.title)
                    }
                }
            }
        }
        var weightUnit: String {
            unitSystemRaw == UnitSystem.metric.rawValue ? "kg" : "lbs"
        }
        
        var displayHeight: String {

            if unitSystemRaw == "metric" {
                
                return "\(height) cm"
                
            } else {
                
                let totalInches = Int(height) ?? 0
                let feet = totalInches / 12
                let inches = totalInches % 12

                return "\(feet)'\(inches)\""
            }
        }
    }
}

#Preview {
    AccountView()
}
