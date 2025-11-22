# IqraWave - Flutter Clean Architecture Starter Template

A production-ready, scalable Flutter starter template implementing **Clean Architecture** with **BLoC** state management pattern. This template provides a solid foundation for building maintainable, testable, and scalable Flutter applications.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with clear separation of concerns across three main layers:

### Layers

```
lib/
├── core/                       # Shared utilities and infrastructure
│   ├── configs/                # App configuration
│   ├── constants/              # Constants (API, storage)
│   ├── di/                     # Dependency injection
│   ├── error/                  # Error handling (failures, exceptions)
│   ├── network/                # Network layer (Dio, interceptors)
│   ├── routes/                 # Navigation/routing
│   ├── theme/                  # Theming system
│   ├── usecase/                # Base use case
│   └── utils/                  # Utilities (logger, etc.)
│
├── features/                   # Feature modules
│   └── [feature_name]/
│       ├── data/               # DATA LAYER
│       │   ├── datasources/    # Remote & local data sources
│       │   ├── models/         # Data models (DTOs)
│       │   └── repositories/   # Repository implementations
│       ├── domain/             # DOMAIN LAYER (Business Logic)
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository contracts
│       │   └── usecases/       # Business use cases
│       └── presentation/       # PRESENTATION LAYER
│           ├── bloc/           # BLoC (state management)
│           ├── pages/          # UI pages/screens
│           └── widgets/        # Reusable widgets
│
└── main.dart                   # Application entry point
```

### Dependency Flow

```
Presentation → Domain ← Data
```

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** has no dependencies (pure business logic)

## 📦 Tech Stack & Packages

### State Management
- **flutter_bloc** (^8.1.6) - BLoC pattern implementation
- **equatable** (^2.0.5) - Value equality

### Dependency Injection
- **get_it** (^8.0.2) - Service locator
- **injectable** (^2.5.0) - Code generation for DI

### Networking
- **dio** (^5.7.0) - HTTP client
- **retrofit** (^4.4.1) - Type-safe REST client
- **pretty_dio_logger** (^1.4.0) - Network logging

### Local Storage
- **shared_preferences** (^2.3.3) - Simple key-value storage
- **flutter_secure_storage** (^9.2.2) - Secure storage

### Functional Programming
- **dartz** (^0.10.1) - Functional programming (Either for error handling)

### Routing
- **go_router** (^14.6.2) - Declarative routing

### Code Generation
- **freezed** (^2.4.5) - Immutable models
- **json_serializable** (^6.8.0) - JSON serialization
- **build_runner** (^2.4.13) - Code generation

### Utilities
- **internet_connection_checker_plus** (^2.5.2) - Network status
- **logger** (^2.5.0) - Logging
- **intl** (^0.20.1) - Internationalization
- **cached_network_image** (^3.4.1) - Image caching

### Testing
- **mocktail** (^1.0.4) - Mocking
- **bloc_test** (^9.1.7) - BLoC testing

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `^3.10.0`
- Dart SDK: `^3.10.0`

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd iqra_wave
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## 🏃 Running the Application

### Development
```bash
flutter run --debug
```

### Release
```bash
flutter run --release
```

### Generate Code (after model changes)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (auto-generate on file changes)
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Test Structure
```
test/
├── features/
│   └── [feature_name]/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── widget_test.dart
```

## 🎨 Features Included

### Core Features

✅ **Clean Architecture** - Proper separation of concerns
✅ **BLoC Pattern** - Reactive state management
✅ **Dependency Injection** - GetIt + Injectable
✅ **Network Layer** - Dio with interceptors
✅ **Error Handling** - Centralized failure handling
✅ **Theming** - Light & Dark mode support
✅ **Routing** - GoRouter navigation
✅ **Code Generation** - Freezed, Injectable, Retrofit
✅ **Testing** - Unit, Widget, and BLoC tests

### Example Implementation

The template includes a complete **Posts feature** demonstrating:

- ✅ Domain entities and use cases
- ✅ Data models and repositories
- ✅ Remote data sources with Dio
- ✅ BLoC for state management
- ✅ UI with proper error handling
- ✅ Pull-to-refresh functionality
- ✅ Loading states
- ✅ Unit and BLoC tests

## 📝 How to Add a New Feature

Follow these steps to add a new feature following Clean Architecture:

### 1. Create Feature Structure

```bash
lib/features/your_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### 2. Domain Layer (Business Logic)

**Entity** (`domain/entities/your_entity.dart`):
```dart
import 'package:equatable/equatable.dart';

class YourEntity extends Equatable {
  final String id;
  final String name;

  const YourEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];
}
```

**Repository Contract** (`domain/repositories/your_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/your_entity.dart';

abstract class YourRepository {
  Future<Either<Failure, List<YourEntity>>> getItems();
}
```

**Use Case** (`domain/usecases/get_items.dart`):
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/your_entity.dart';
import '../repositories/your_repository.dart';

@lazySingleton
class GetItems implements UseCase<List<YourEntity>, NoParams> {
  final YourRepository repository;

  GetItems(this.repository);

  @override
  Future<Either<Failure, List<YourEntity>>> call(NoParams params) async {
    return await repository.getItems();
  }
}
```

### 3. Data Layer

**Model** (`data/models/your_model.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/your_entity.dart';

part 'your_model.freezed.dart';
part 'your_model.g.dart';

@freezed
class YourModel with _$YourModel {
  const factory YourModel({
    required String id,
    required String name,
  }) = _YourModel;

  factory YourModel.fromJson(Map<String, dynamic> json) =>
      _$YourModelFromJson(json);
}

extension YourModelX on YourModel {
  YourEntity toEntity() {
    return YourEntity(id: id, name: name);
  }
}
```

**Data Source** (`data/datasources/your_remote_data_source.dart`):
```dart
import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/your_model.dart';

abstract class YourRemoteDataSource {
  Future<List<YourModel>> getItems();
}

@LazySingleton(as: YourRemoteDataSource)
class YourRemoteDataSourceImpl implements YourRemoteDataSource {
  final DioClient _dioClient;

  YourRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<YourModel>> getItems() async {
    final response = await _dioClient.dio.get('/items');
    return (response.data as List)
        .map((json) => YourModel.fromJson(json))
        .toList();
  }
}
```

**Repository Implementation** (`data/repositories/your_repository_impl.dart`):
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/your_entity.dart';
import '../../domain/repositories/your_repository.dart';
import '../datasources/your_remote_data_source.dart';

@LazySingleton(as: YourRepository)
class YourRepositoryImpl implements YourRepository {
  final YourRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  YourRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<YourEntity>>> getItems() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await remoteDataSource.getItems();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

### 4. Presentation Layer

**BLoC** (`presentation/bloc/your_bloc.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_items.dart';

// Event, State, and BLoC implementation
@injectable
class YourBloc extends Bloc<YourEvent, YourState> {
  final GetItems getItems;

  YourBloc(this.getItems) : super(const YourInitial()) {
    on<LoadItems>(_onLoadItems);
  }

  Future<void> _onLoadItems(
    LoadItems event,
    Emitter<YourState> emit,
  ) async {
    emit(const YourLoading());
    final result = await getItems(NoParams());
    result.fold(
      (failure) => emit(YourError(failure.message)),
      (items) => emit(YourLoaded(items)),
    );
  }
}
```

### 5. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎯 Environment Configuration

Configure different environments in `lib/core/configs/app_config.dart`:

```dart
AppConfig.setEnvironment(Environment.dev);    // Development
AppConfig.setEnvironment(Environment.staging); // Staging
AppConfig.setEnvironment(Environment.prod);    // Production
```

## 🔐 API Configuration

Update API endpoints in `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String devBaseUrl = 'https://dev-api.example.com';
  static const String stagingBaseUrl = 'https://staging-api.example.com';
  static const String prodBaseUrl = 'https://api.example.com';

  // Endpoints
  static const String login = '/auth/login';
  static const String users = '/users';
}
```

## 🎨 Theming

The app supports light and dark themes. Toggle theme using:

```dart
context.read<ThemeCubit>().toggleTheme();
```

Customize themes in:
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_colors.dart`

## 🧩 Dependency Injection

Dependencies are automatically injected using **Injectable** and **GetIt**.

Access dependencies:
```dart
final bloc = getIt<YourBloc>();
```

Register new dependencies in their respective files with annotations:
- `@injectable` - Regular dependency
- `@lazySingleton` - Lazy singleton
- `@singleton` - Eager singleton

## 📱 Example Screens

### Splash Screen
Initial loading screen with app branding

### Home Screen
Landing page with feature showcase

### Posts Screen
Complete CRUD example with:
- Data fetching from API
- Loading states
- Error handling
- Pull-to-refresh

## 🐛 Error Handling

Centralized error handling with custom failures:

- `ServerFailure` - API errors
- `NetworkFailure` - No internet connection
- `CacheFailure` - Local storage errors
- `ValidationFailure` - Input validation
- `AuthenticationFailure` - Auth errors

## 📚 Best Practices

✅ **Separation of Concerns** - Each layer has a single responsibility
✅ **Dependency Inversion** - Depend on abstractions, not concretions
✅ **Single Responsibility** - One class, one purpose
✅ **Testability** - Easy to mock and test
✅ **Immutability** - Use Freezed for immutable models
✅ **Error Handling** - Either<Failure, Success> pattern
✅ **Code Generation** - Reduce boilerplate

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Clean Architecture by Robert C. Martin
- Flutter BLoC pattern
- Community packages and contributors

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact the maintainers

---

**Happy Coding! 🚀**

Built with ❤️ using Flutter and Clean Architecture
# iqra_wave
