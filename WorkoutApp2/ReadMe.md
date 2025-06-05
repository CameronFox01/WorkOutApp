# 💪 SwiftUI Workout Tracker App

A simple, expandable workout tracking app built with SwiftUI. Track your workouts, monitor your progress, and visualize changes with side-by-side photos.

---

## 📋 App Roadmap

### 1. 'AccountView' -**Completed**
**Small UpDates** I just need to pretty it up. But I think it is completed for all the backend stuff. 

### 2. 🏠 `HomeView` — **Next**
**Why**: This is your dashboard. Start simple and build from there.

**Start with:**
- Display data from `AccountView`
- Show recent workouts (use mock data if needed)
- Show basic stats like:
  - Total workouts
  - Average reps

**Later expand to:**
- Progress charts
- Weight trends (e.g., weekly averages)
- Goal tracking (e.g., “Workout 3x/week”)

---

### 3. 📥 `ImportView` — **Then this**
**Why**: Core functionality — logging workouts is what powers your progress tracking.

**Start with:**
- Date picker
- Dropdown or text input for exercise name
- Fields for sets/reps
- Save to list (in-memory or `@AppStorage`)

**Later expand to:**
- Save to file or CoreData
- Display list of previous workouts
- Allow editing/deleting entries

---

### 4. 📸 `PhotoView` — **Last**
**Why**: Powerful feature, but not essential to MVP. Also, it’s the most complex technically.

**Break into stages:**
1. Allow photo import (from camera or gallery)
2. Save/display photos in a grid
3. Enable selecting two photos to compare side-by-side

**Optional enhancements:**
- Add tags or dates to photos
- Create a slider or overlay comparison tool

**Tech Tip**:  
- Use `PhotosPicker` (iOS 16+) for easy imports  
- Use `UIImagePickerController` for more control/customization

---

## 🧱 Suggested File Structure


