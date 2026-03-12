# 📦 Stock-Count-Bin-M


StockCount is a SwiftUI-based iOS inventory management app built for small retail businesses.  
It allows store owners to manage clothing items, track profit margins, organize categories, and export inventory data.

Built by **Mohamed Kaid**

---

## 🚀 Features

- Add, edit, and delete inventory items  
- Track cost price, sale price, profit, and margin  
- Organize items by dynamic categories  
- Quantity tracking  
- Season, size, and color selection  
- Auto-fill from last item  
- Export inventory to CSV  
- Local JSON persistence  
- Firebase-ready setup  


---

## 📱 Screenshots

### 🏠 Dashboard
<img width="230" height="600" alt="Screenshot 2026-03-11 at 10 02 22 AM" src="https://github.com/user-attachments/assets/d15f3f27-bab9-40de-9060-5fb276ffb69e" />

### 🗂 Category Management
<img width="230" height="600" alt="Screenshot 2026-03-11 at 10 05 19 AM" src="https://github.com/user-attachments/assets/cf99186f-36b0-4cac-919d-e748f1000d44" />

### 👕 Add / Edit Item
<img width="230" height="600" alt="Screenshot 2026-03-11 at 10 05 47 AM" src="https://github.com/user-attachments/assets/55f27987-47d5-4777-a6ad-5c2e4b0a5719" />
<img width="230" height="600" alt="Screenshot 2026-03-11 at 10 06 20 AM" src="https://github.com/user-attachments/assets/0ee7f3e5-9df5-423a-b19f-a928b81f12bf" />

### 📤 CSV Export
<img width="600" height="250" alt="Open stockCount_inventory_2026-03-11_10-06-43_D392F24F-5541-40B8-A8C3-14B55C491AAC 2" src="https://github.com/user-attachments/assets/b132681f-1f6e-4898-b642-3bb6c30778c4" />

---

## 🧱 Architecture

- SwiftUI  
- MVVM-style structure  
- `@EnvironmentObject` state management  
- Codable + JSON local storage  
- Combine  
- FirebaseCore  

---

## 💾 Data Storage

Inventory and categories are saved locally as JSON files and automatically persist between app launches.

---

## 📤 Export

Generate and share a CSV file of your full inventory with category mapping included.

---

## 🛠 Tech Stack

Swift • SwiftUI • Combine • Codable • FirebaseCore • iOS ShareLink

---

## 🎯 Purpose

Designed for small clothing retailers who need a simple, fast, offline-first inventory management solution.
