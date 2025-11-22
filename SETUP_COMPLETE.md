# ✅ Setup Complete - IqraWave Flutter Template

## 🎉 Congratulations!

Your Flutter Clean Architecture + BLoC starter template is now fully set up and ready to use!

## 📋 What's Been Implemented

### ✅ Core Infrastructure
- **Clean Architecture layers**: Data, Domain, Presentation
- **Dependency Injection**: GetIt + Injectable configured
- **Network Layer**: Dio with interceptors (Auth, Error, Logging)
- **Error Handling**: Centralized Failures and Exceptions
- **Theme System**: Light & Dark mode with ThemeCubit
- **Routing**: GoRouter with type-safe navigation
- **Configuration**: Environment-based config (Dev, Staging, Prod)

### ✅ Features Implemented
1. **Splash Screen** - Animated loading screen
2. **Home Screen** - Feature showcase with theme toggle
3. **Posts Feature** - Complete Clean Architecture example:
   - Domain: Entities, Use Cases, Repository contracts
   - Data: Models, Data Sources, Repository implementations
   - Presentation: BLoC, Pages, Widgets

### ✅ Testing Setup
- Unit tests for Use Cases
- BLoC tests with bloc_test
- Widget tests
- Test mocking with Mocktail

### ✅ Code Generation
- Freezed for immutable models
- Injectable for dependency injection
- JSON Serialization
- Retrofit for API clients

## 🚀 Quick Start Commands

### Install Dependencies
```bash
flutter pub get
```

### Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run the App
```bash
flutter run
```

### Run Tests
```bash
flutter test
```

## 📂 Project Structure

```
iqra_wave/
├── lib/
│   ├── core/                       # Shared infrastructure
│   │   ├── configs/                # App config
│   │   ├── constants/              # API & storage constants
│   │   ├── di/                     # Dependency injection
│   │   ├── error/                  # Failures & exceptions
│   │   ├── network/                # Dio client & interceptors
│   │   ├── routes/                 # Navigation
│   │   ├── theme/                  # Theming
│   │   ├── usecase/                # Base use case
│   │   └── utils/                  # Logger, etc.
│   │
│   ├── features/                   # Feature modules
│   │   ├── home/                   # Home feature
│   │   ├── posts/                  # Posts feature (example)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── splash/                 # Splash screen
│   │
│   └── main.dart                   # App entry point
│
├── test/                           # Tests
│   ├── features/
│   │   └── posts/
│   │       ├── domain/
│   │       └── presentation/
│   └── widget_test.dart
│
├── pubspec.yaml                    # Dependencies
├── analysis_options.yaml           # Lint rules
└── README.md                       # Documentation
```

## 🔥 Key Features

### 1. Clean Architecture
```
Presentation → Domain ← Data
```
- Clear separation of concerns
- Testable business logic
- Independent layers

### 2. BLoC Pattern
- Event-driven state management
- Reactive UI updates
- Separation of business logic from UI

### 3. Dependency Injection
```dart
// Automatic injection with Injectable
@lazySingleton
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPosts getPosts;
  PostsBloc(this.getPosts) : super(const PostsInitial());
}

// Access anywhere
final bloc = getIt<PostsBloc>();
```

### 4. Error Handling
```dart
// Either type for elegant error handling
Future<Either<Failure, List<Post>>> getPosts() async {
  if (!await networkInfo.isConnected) {
    return const Left(NetworkFailure());
  }

  try {
    final posts = await remoteDataSource.getPosts();
    return Right(posts.map((m) => m.toEntity()).toList());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

### 5. Type-Safe Models
```dart
@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required int id,
    required String title,
    required String body,
    required int userId,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);
}
```

## 📝 Next Steps

### 1. Customize the App
- Update app name in `pubspec.yaml` and `AppConfig`
- Change theme colors in `lib/core/theme/app_colors.dart`
- Update API base URL in `lib/core/constants/api_constants.dart`

### 2. Add Your Features
Follow the clean architecture pattern:
1. Create domain entities and use cases
2. Implement data models and repositories
3. Build presentation layer with BLoC
4. Write tests for each layer

### 3. Configure Environments
```dart
// in main.dart
AppConfig.setEnvironment(Environment.dev);    // Development
AppConfig.setEnvironment(Environment.staging); // Staging
AppConfig.setEnvironment(Environment.prod);    // Production
```

### 4. API Integration
Update your API endpoints in:
- `lib/core/constants/api_constants.dart`
- `lib/core/network/api_client.dart`

Then run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎯 Example: Posts Feature

The Posts feature demonstrates the complete architecture:

### Domain Layer
```dart
// Entity
class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
}

// Use Case
class GetPosts implements UseCase<List<Post>, NoParams> {
  Future<Either<Failure, List<Post>>> call(NoParams params) {
    return repository.getPosts();
  }
}
```

### Data Layer
```dart
// Model with Freezed
@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required int id,
    required String title,
    required String body,
    required int userId,
  }) = _PostModel;
}

// Repository Implementation
class PostRepositoryImpl implements PostRepository {
  Future<Either<Failure, List<Post>>> getPosts() async {
    // Network check, API call, error handling
  }
}
```

### Presentation Layer
```dart
// BLoC
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc(this.getPosts) : super(const PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
  }
}

// UI
BlocBuilder<PostsBloc, PostsState>(
  builder: (context, state) {
    if (state is PostsLoaded) {
      return ListView.builder(...);
    }
    return CircularProgressIndicator();
  },
)
```

## 🧪 Testing

### Unit Tests
```dart
test('should get list of posts from the repository', () async {
  when(() => mockRepository.getPosts())
      .thenAnswer((_) async => const Right(tPosts));

  final result = await usecase(NoParams());

  expect(result, const Right(tPosts));
  verify(() => mockRepository.getPosts());
});
```

### BLoC Tests
```dart
blocTest<PostsBloc, PostsState>(
  'emits [PostsLoading, PostsLoaded] when data is gotten successfully',
  build: () => bloc,
  act: (bloc) => bloc.add(const LoadPosts()),
  expect: () => [
    const PostsLoading(),
    const PostsLoaded(tPosts),
  ],
);
```

## 📚 Resources

- [README.md](README.md) - Complete documentation
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Documentation](https://flutter.dev/docs)

## 💡 Tips

1. **Always run code generation** after changing models:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Use watch mode** during development:
   ```bash
   flutter pub run build_runner watch
   ```

3. **Follow the architecture** - Keep domain layer pure (no Flutter imports)

4. **Write tests** - The architecture makes testing easy

5. **Use the example** - The Posts feature shows best practices

## 🐛 Troubleshooting

### Code Generation Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Injection Issues
Make sure SharedPreferences is registered in `main.dart` before calling `configureDependencies()`.

### Import Errors
The linter will warn about using relative imports. These are informational and the app will work fine.

## ✨ What Makes This Template Special

✅ **Production-Ready** - Not just a demo, ready for real projects
✅ **Scalable** - Add features easily following the pattern
✅ **Testable** - High test coverage possible
✅ **Maintainable** - Clear structure, easy to understand
✅ **Type-Safe** - Freezed, Retrofit, strong typing everywhere
✅ **Modern** - Latest packages and best practices
✅ **Complete** - All infrastructure already set up

## 🚀 Start Building!

You now have a professional Flutter starter template with:
- ✅ Clean Architecture
- ✅ BLoC State Management
- ✅ Dependency Injection
- ✅ Network Layer
- ✅ Error Handling
- ✅ Theming
- ✅ Routing
- ✅ Testing
- ✅ Code Generation

**Ready to build something amazing!** 🎉

---

**Happy Coding!** 🚀

For questions or issues, check the README.md or create an issue on GitHub.
