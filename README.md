# CrewChat

A SwiftUI-based chat interface app with support for text and image messages, built with MVVM architecture.

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2018.6+-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)

> App Walkthrough Videos - https://drive.google.com/drive/folders/1l-ZqwWiFrwYOsPKd40sPfcgD90_j42Vr?usp=sharing

## Setup Instructions

### Requirements

- Xcode 21.0+
- iOS 18.6+
- Swift 5+

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yash22arora/crew-message-viewer.git
   ```
2. Open `CrewChat/CrewChat.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘+R)

### First Launch

On first launch, the app creates a default "Mumbai Trip" chat with seed messages demonstrating various message types.

---

## Architecture

### MVVM + DataManager Pattern

```mermaid
graph TB
    subgraph Views["📱 Views Layer"]
        HV[HomeView]
        CV[ChatView]
        MBV[MessageBubbleView]
        IMV[ImageMessageView]
        MIB[MessageInputBar]
    end

    subgraph ViewModels["🧠 ViewModels Layer"]
        HVM[HomeViewModel]
        CVM[ChatViewModel]
    end

    subgraph DataManagers["📊 DataManagers Layer"]
        CDM[ChatsDataManager]
        MDM[MessagesDataManager]
    end

    subgraph Services["⚙️ Services Layer"]
        PS[PersistenceService]
        SDL[SeedDataLoader]
        ISS[ImageStorageService]
    end

    subgraph Storage["💾 Storage Layer"]
        CJ[(chats.json)]
        MJ[(chatId_messages.json)]
        IMG[(Images/)]
    end

    HV --> HVM
    CV --> CVM
    CV --> MBV
    MBV --> IMV
    CV --> MIB

    HVM --> CDM
    CVM --> MDM

    CDM --> PS
    MDM --> PS
    SDL --> PS
    CVM --> ISS

    PS --> CJ
    PS --> MJ
    ISS --> IMG
```

### Layer Responsibilities

| Layer            | Responsibility                                                 |
| ---------------- | -------------------------------------------------------------- |
| **Views**        | UI rendering, user interaction, state binding                  |
| **ViewModels**   | Business logic, state management, data transformation          |
| **DataManagers** | Data access abstraction, protocol-based for testability        |
| **Services**     | Low-level I/O operations, file system access, image processing |
| **Storage**      | JSON files for persistence, Images directory for media         |

### Key Design Decisions

| Decision                        | Rationale                                                                            |
| ------------------------------- | ------------------------------------------------------------------------------------ |
| **MVVM Pattern**                | Clean separation between UI and business logic; ViewModels are testable in isolation |
| **Protocol-based DataManagers** | Enables dependency injection and mocking for unit tests                              |
| **Per-chat Message Storage**    | `<chatId>_messages.json` allows independent chat histories and scalability           |
| **@StateObject for ViewModels** | Ensures single initialization when views are recreated by SwiftUI                    |
| **Seed Data from JSON**         | Externalized test data makes it easy to modify without recompiling                   |

### Project Structure

```
CrewChat/
├── 📱 Views/
│   ├── HomeView.swift              # Chat list screen
│   ├── ChatView.swift              # Main chat interface
│   ├── MessageBubbleView.swift     # Message container with context menu
│   ├── TextMessageView.swift       # Text message content
│   ├── ImageMessageView.swift      # Image message with async loading
│   ├── FullScreenImageView.swift   # Zoomable image viewer
│   ├── MessageInputBar.swift       # Text input with send button
│   ├── ImagePicker.swift           # Camera/Library picker wrapper
│   ├── ImageSourcePickerSheet.swift# Bottom sheet for image source
│   └── ImagePreviewBarView.swift   # Preview before sending image
│
├── 🧠 ViewModels/
│   ├── HomeViewModel.swift         # Manages chat list state
│   └── ChatViewModel.swift         # Manages messages and sending
│
├── 📊 DataManager/
│   ├── ChatsDataManager.swift      # Chat CRUD operations
│   └── MessagesDataManager.swift   # Agent response simulation
│
├── ⚙️ Services/
│   ├── PersistenceService.swift    # JSON file I/O for chats & messages
│   ├── SeedDataLoader.swift        # First-launch data seeding
│   └── ImageStorageService.swift   # Image compression & storage
│
├── 📦 Models/
│   ├── Chat.swift                  # Chat model (id, label, createdAt)
│   └── Message.swift               # Message model with FileInfo
│
├── 🛠️ Utilities/
│   ├── Constants.swift             # App-wide constants & keys
│   └── DateFormatters.swift        # Smart timestamp formatting
│
├── 📁 Resources/
│   └── SeedMessages.json           # Default messages for first launch
│
└── CrewChatApp.swift               # App entry point
```

---

## Features

### Core Features

- ✅ Text and image message support
- ✅ Optional Caption for images
- ✅ Image picking from Camera and Photo Library
- ✅ Full-screen zoomable image viewer
- ✅ Chronological message display with smart timestamps
- ✅ Message persistence to local JSON storage
- ✅ Seed data on first launch (for default chat)
- ✅ Keyboard handling with auto-scroll

### Bonus Features

| Feature                           | Description                                                                      |
| --------------------------------- | -------------------------------------------------------------------------------- |
| 🖼️ **Image Preview with Caption** | Preview selected images before sending with optional caption, ability to dismiss |
| 📋 **Long-press Context Menu**    | Native iOS context menu to copy message text                                     |
| ⌨️ **Smart Keyboard Handling**    | Scroll-to-dismiss, tap-to-dismiss, auto-scroll on keyboard show                  |
| 🔄 **Orientation Support**        | Auto-scrolls to bottom on device rotation                                        |
| ⏳ **Typing Indicator**           | Animated bouncing dots while agent is responding                                 |
| 🕐 **Smart Timestamps**           | "Just now", "2 minutes ago", "Today at 3:30 PM", etc.                            |
| 🌐 **External Image URLs**        | Support for both local and remote images via AsyncImage                          |
| 📱 **Multi-chat Architecture**    | Per-chat message storage ready for multiple conversations                        |
| 📳 **Haptic Feedback**            | Tactile feedback on copy action                                                  |
| 🌅 **Image Compression**          | Compressing images before saving with a compression quality of 0.8               |

---

## Data Flow

### Text Message Flow

```mermaid
sequenceDiagram
    participant User
    participant MessageInputBar
    participant ChatViewModel
    participant PersistenceService
    participant MessagesDataManager

    User->>MessageInputBar: Types message
    User->>MessageInputBar: Taps Send
    MessageInputBar->>ChatViewModel: sendMessage(text)
    ChatViewModel->>ChatViewModel: Create Message object
    ChatViewModel->>PersistenceService: saveMessages(for: chatId)
    PersistenceService-->>ChatViewModel: Success
    ChatViewModel->>MessagesDataManager: fetchAgentResponse()
    Note over MessagesDataManager: Simulated delay (0.5-2.5s)
    MessagesDataManager-->>ChatViewModel: Agent Message
    ChatViewModel->>PersistenceService: saveMessages(for: chatId)
```

### Image Message Flow

```mermaid
sequenceDiagram
    participant User
    participant ChatView
    participant ImagePicker
    participant ImageStorageService
    participant ChatViewModel
    participant PersistenceService
    participant MessagesDataManager

    User->>ChatView: Taps attachment button
    ChatView->>ChatView: Show ImageSourcePicker
    User->>ChatView: Selects Camera/Library
    ChatView->>ImagePicker: Present picker
    User->>ImagePicker: Selects image
    ImagePicker->>ChatView: handleSelectedImage(image)
    ChatView->>ChatView: pendingImage = image
    ChatView->>ChatView: Show preview with ability to discard
    User->>ChatView: Types caption (optional)
    User->>ChatView: Taps Send
    ChatView->>ImageStorageService: saveImage(image)
    ImageStorageService-->>ChatView: (path, size)
    ChatView->>ChatViewModel: sendImageMessage(path, size, caption)
    ChatViewModel->>ChatViewModel: Create Message object
    Note over ChatView: Clear pendingImage
    ChatViewModel->>PersistenceService: saveMessages(for: chatId)
    PersistenceService-->>ChatViewModel: Success
    ChatViewModel->>MessagesDataManager: fetchAgentResponse()
    Note over MessagesDataManager: Simulated delay (0.5-2.5s)
    MessagesDataManager-->>ChatViewModel: Agent Message
    ChatViewModel->>PersistenceService: saveMessages(for: chatId)
```

### App Launch Flow

```mermaid
flowchart TD
    A[App Launch] --> B{chats.json exists?}
    B -->|No| C[Create default Mumbai Trip chat]
    C --> D[Save to chats.json]
    D --> E[HomeView displays chats]
    B -->|Yes| E
    E --> F[User taps chat]
    F --> G[ChatView opens]
    G --> H{Is default chat?}
    H -->|Yes| I{Seed data loaded?}
    I -->|No| J[Load SeedMessages.json]
    J --> K[Save to chatId_messages.json]
    K --> L[Display messages]
    I -->|Yes| L
    H -->|No| L
```
