# ASL Learning App: Architecture Overview

Below is a simplified architecture diagram showing the main components of the ASL Learning app ecosystem:

```mermaid
graph TD
    %% Client Side
    subgraph "iOS Mobile App"
        UI[SwiftUI Interface]
        CoreMLModels[CoreML Models]
        MediaPipe[MediaPipe Tasks Vision]
        NetworkService[Network Service]
        LocalCache[Keychain/UserDefaults]
    end

    %% Server Side
    subgraph "Backend Server"
        NestJS[NestJS API]
        PrismaORM[Prisma ORM]
        SharedCache[Redis Cache]
        Authentication[Auth Service]
        BadgesService[Badges Service]
        QuizesService[Quizes Service]
        UsersService[Users Service]
        PhrasesService[Phrases Service]
    end

    %% External Services
    subgraph "Storage Services"
        Postgres[PostgreSQL Database]
        S3[AWS S3 Storage]
    end

    subgraph "ML Training Pipeline"
        PyTorch[Python/PyTorch Training]
        MediaPipeHolistic[MediaPipe Holistic]
        CoreMLConverter[CoreML Converter]
    end

    %% Connections
    UI --> CoreMLModels
    UI --> MediaPipe
    UI --> NetworkService
    UI --> LocalCache
    
    MediaPipe --> CoreMLModels
    
    NetworkService --> NestJS
    
    NestJS --> PrismaORM
    NestJS --> SharedCache
    NestJS --> Authentication
    NestJS --> BadgesService
    NestJS --> QuizesService
    NestJS --> UsersService
    NestJS --> PhrasesService
    
    PrismaORM --> Postgres
    
    PyTorch --> MediaPipeHolistic
    PyTorch --> CoreMLConverter
    CoreMLConverter --> CoreMLModels
    
    PhrasesService --> S3
    QuizesService --> S3

    %% Style definitions
    classDef ios fill:#f9f9ff,stroke:#6495ED,stroke-width:2px;
    classDef backend fill:#E6F7FF,stroke:#0078D7,stroke-width:2px;
    classDef storage fill:#FFEBF3,stroke:#FF69B4,stroke-width:2px;
    classDef ml fill:#FFFACD,stroke:#DAA520,stroke-width:2px;
    
    %% Apply styles
    class UI,CoreMLModels,MediaPipe,NetworkService,LocalCache ios;
    class NestJS,PrismaORM,SharedCache,Authentication,BadgesService,QuizesService,UsersService,PhrasesService backend;
    class Postgres,S3 storage;
    class PyTorch,MediaPipeHolistic,CoreMLConverter ml;
```

## Architecture Explanation

### Client Side (iOS App)
- **SwiftUI Interface**: Declarative UI framework used to build the user interface
- **CoreML Models**: On-device machine learning models for ASL recognition
- **MediaPipe Tasks Vision**: Framework for processing camera input and detecting hand landmarks
- **Network Service**: Handles all API communication with the backend
- **Local Cache**: Stores authentication tokens and user preferences

### Backend Server
- **NestJS API**: TypeScript-based server framework providing RESTful endpoints
- **Prisma ORM**: Type-safe database client for interacting with PostgreSQL
- **Redis Cache**: In-memory data store for caching frequent requests
- **Service Modules**: Modular architecture with specialized services

### Storage Services
- **PostgreSQL Database**: Primary database storing all application data
- **AWS S3 Storage**: Object storage for ASL videos, GIFs, and other media

### ML Training Pipeline
- **Python/PyTorch Training**: ML model training using deep learning frameworks
- **MediaPipe Holistic**: Framework for extracting full-body pose, face, and hand landmarks
- **CoreML Converter**: Converts trained models to CoreML format for iOS deployment

This architecture follows modern best practices with a clear separation of concerns between frontend, backend, and ML components, while ensuring efficient real-time processing for ASL recognition.
