# POS Offline - Point of Sale System

Aplikasi POS (Point of Sale) offline modern yang dibangun dengan Flutter, SQLite, dan GetX. Aplikasi ini dirancang untuk kasir toko retail dengan fitur lengkap dan UI yang clean & responsive.

## 🚀 Fitur Utama

### 1. **Authentication (Login/Logout)**
- ✅ Login offline menggunakan SQLite
- ✅ Role-based access (Admin & Kasir)
- ✅ Session persistence
- ✅ Switch user untuk testing
- ✅ Forgot password simulation

### 2. **User Management (Admin Only)**
- ✅ CRUD User lengkap
- ✅ Role & Permission management
- ✅ User profile & change password
- ✅ Active/Inactive status
- ✅ Search & filter users

### 3. **Product Management**
- ✅ CRUD Produk lengkap
- ✅ Stock management
- ✅ Category filter
- ✅ Product search by name/SKU/barcode
- ✅ Low stock indicator
- ✅ Responsive grid/list view

### 4. **Point of Sale (POS)**
- ✅ Product catalog dengan search
- ✅ Shopping cart management
- ✅ Quantity & discount per item
- ✅ Transaction discount & tax
- ✅ Multiple payment methods (Cash/Card)
- ✅ Change calculation
- ✅ Transaction history
- ✅ Print placeholder (siap untuk implementasi)

## 📁 Struktur Project

```
lib/
├── app/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Theme configuration
│   │   ├── utils/
│   │   │   └── db_helper.dart          # SQLite database helper
│   │   └── widgets/                     # Reusable widgets
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       ├── custom_card.dart
│   │       ├── custom_badge.dart
│   │       ├── empty_state.dart
│   │       ├── loading_overlay.dart
│   │       └── confirm_dialog.dart
│   │
│   ├── modules/
│   │   ├── splash/                      # Splash screen
│   │   │   ├── splash_view.dart
│   │   │   ├── splash_controller.dart
│   │   │   └── splash_binding.dart
│   │   │
│   │   ├── auth/                        # Authentication
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── views/
│   │   │   │   └── login_view.dart
│   │   │   ├── auth_controller.dart
│   │   │   └── auth_binding.dart
│   │   │
│   │   ├── user/                        # User Management
│   │   │   ├── providers/
│   │   │   │   └── user_provider.dart
│   │   │   ├── repositories/
│   │   │   │   └── user_repository.dart
│   │   │   ├── views/
│   │   │   │   ├── user_list_view.dart
│   │   │   │   ├── user_form_view.dart
│   │   │   │   └── profile_view.dart
│   │   │   ├── user_controller.dart
│   │   │   └── user_binding.dart
│   │   │
│   │   ├── product/                     # Product Management
│   │   │   ├── models/
│   │   │   │   └── product_model.dart
│   │   │   ├── providers/
│   │   │   │   └── product_provider.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   ├── views/
│   │   │   │   ├── product_list_view.dart
│   │   │   │   └── product_form_view.dart
│   │   │   ├── product_controller.dart
│   │   │   └── product_binding.dart
│   │   │
│   │   ├── pos/                         # Point of Sale
│   │   │   ├── models/
│   │   │   │   ├── transaction_model.dart
│   │   │   │   ├── transaction_item_model.dart
│   │   │   │   └── cart_item_model.dart
│   │   │   ├── providers/
│   │   │   │   └── transaction_provider.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   ├── views/
│   │   │   │   ├── pos_view.dart
│   │   │   │   └── transaction_history_view.dart
│   │   │   ├── pos_controller.dart
│   │   │   └── pos_binding.dart
│   │   │
│   │   └── home/                        # Home/Dashboard
│   │       ├── home_view.dart
│   │       ├── home_controller.dart
│   │       └── home_binding.dart
│   │
│   └── routes/
│       ├── app_routes.dart              # Route constants
│       └── app_pages.dart               # Route pages
│
└── main.dart                            # App entry point
```

## 🛠️ Teknologi yang Digunakan

- **Flutter SDK** (>= 3.0.0)
- **GetX** (4.6.6) - State Management, Routing, Dependency Injection
- **SQLite** (sqflite 2.3.0) - Local Database
- **Google Fonts** (6.1.0) - Typography
- **Intl** (0.18.1) - Internationalization & Number Formatting
- **UUID** (4.2.2) - Unique ID Generation
- **Shared Preferences** (2.2.2) - Local Storage

## 📦 Instalasi & Setup

### 1. Prerequisites
Pastikan Anda sudah menginstall:
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android Emulator atau Physical Device

### 2. Clone & Install Dependencies

```bash
# Clone repository (jika dari Git)
git clone <repository-url>
cd pos_offline

# Install dependencies
flutter pub get

# Run code generation (jika ada)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Jalankan Aplikasi

```bash
# Run di emulator/device
flutter run

# Run untuk web
flutter run -d chrome

# Run untuk desktop (Windows/Mac/Linux)
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Build APK untuk production
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## 👤 Akun Testing

Aplikasi sudah dilengkapi dengan akun testing default:

### Admin
- **Username:** `admin`
- **Password:** `admin123`
- **Akses:** Full access ke semua fitur

### Kasir
- **Username:** `kasir1`
- **Password:** `kasir123`
- **Akses:** POS, Transaksi, dan Produk (read-only)

## 🎨 Desain & UI

### Theme
- **Light Mode** & **Dark Mode** support
- Color scheme: Fresh Blue (#2196F3)
- Clean, minimalist, modern design
- Responsive layout untuk mobile, tablet, dan desktop

### Responsive Breakpoints
- **Mobile:** < 600px
- **Tablet:** 600px - 800px
- **Desktop:** > 800px

### UI Components
Semua komponen UI dapat digunakan kembali (reusable):
- CustomButton
- CustomTextField
- CustomCard
- CustomBadge
- EmptyState
- LoadingOverlay
- ConfirmDialog

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  fullName TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'kasir',
  isActive INTEGER NOT NULL DEFAULT 1,
  avatarPath TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

### Products Table
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sku TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  buyPrice REAL NOT NULL DEFAULT 0,
  sellPrice REAL NOT NULL DEFAULT 0,
  stock INTEGER NOT NULL DEFAULT 0,
  minStock INTEGER DEFAULT 0,
  barcode TEXT,
  imagePath TEXT,
  isActive INTEGER NOT NULL DEFAULT 1,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transactionCode TEXT UNIQUE NOT NULL,
  userId INTEGER NOT NULL,
  userName TEXT NOT NULL,
  subtotal REAL NOT NULL,
  discount REAL NOT NULL DEFAULT 0,
  tax REAL NOT NULL DEFAULT 0,
  total REAL NOT NULL,
  paid REAL NOT NULL,
  change REAL NOT NULL DEFAULT 0,
  paymentMethod TEXT NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'completed',
  createdAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users (id)
)
```

### Transaction Items Table
```sql
CREATE TABLE transaction_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transactionId INTEGER NOT NULL,
  productId INTEGER NOT NULL,
  productName TEXT NOT NULL,
  sku TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  discount REAL NOT NULL DEFAULT 0,
  subtotal REAL NOT NULL,
  FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE,
  FOREIGN KEY (productId) REFERENCES products (id)
)
```

## 🧪 Testing

### Unit Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_controller_test.dart

# Run with coverage
flutter test --coverage
```

### Test Files (Contoh)
```
test/
├── auth_controller_test.dart
├── pos_controller_test.dart
└── product_controller_test.dart
```

## 🔮 Roadmap & Fitur Selanjutnya

### Phase 2 - Advanced Features
- [ ] Print receipt (thermal printer support)
- [ ] Export data to CSV/Excel
- [ ] Import products from CSV
- [ ] Barcode scanner integration
- [ ] Advanced reporting & analytics
- [ ] Multi-store support
- [ ] Cloud sync (optional)

### Phase 3 - Additional Modules
- [ ] Purchase/Stock In management
- [ ] Supplier management
- [ ] Expense tracking
- [ ] Customer management & loyalty
- [ ] Dashboard with charts
- [ ] Backup & restore database

## 📝 Catatan Penting

1. **Password Security:** Untuk production, gunakan hashing (bcrypt/argon2) untuk password
2. **Session Management:** Token expiry sudah diimplementasi (30 hari)
3. **Stock Management:** Stock otomatis berkurang saat transaksi
4. **Transaction Code:** Auto-generated dengan format TRXYYYYMMDDHHmmss
5. **SKU:** Auto-generated dengan format PRDYYYYMMDDHHMI

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:
1. Fork repository
2. Buat branch baru (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Developer

Dibuat dengan ❤️ menggunakan Flutter & GetX

---

**Happy Coding! 🚀**