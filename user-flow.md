# ASL Learning App User Flow

This diagram illustrates the complete user journey through the ASL Learning mobile application, from initial registration to accessing various learning features.

```mermaid
flowchart TD
    subgraph "Authentication Flow"
        start([User Opens App]) --> auth{Authenticated?}
        auth -->|No| register[Create New<br/>Account]
        auth -->|No| signin[Sign In]
        auth -->|Yes| dashboard[Main<br/>Dashboard]
        
        register --> referral{Has Referral<br/>Code?}
        referral -->|Yes| enterRef[Enter Referral<br/>Code]
        referral -->|No| completeReg[Complete<br/>Registration]
        enterRef --> completeReg
        completeReg --> dashboard
        
        signin --> dashboard
    end
    
    subgraph "Main Application Features"
        dashboard --> learn[Quizzes<br/>Tab]
        dashboard --> practice[Camera<br/>Tab]
        dashboard --> phrases[Wiki<br/>Tab]
        dashboard --> explore[Explore<br/>Tab]
        dashboard --> profile[Profile<br/>Tab]
        
        learn --> quizList[View Available<br/>Quizzes]
        quizList --> bubbleQuiz[Bubble<br/>Quiz]
        quizList --> matchingQuiz[Matching<br/>Quiz]
        quizList --> alphabetQuiz[Alphabet Streak<br/>Quiz]
        
        bubbleQuiz --> camera1[Camera<br/>Recognition]
        matchingQuiz --> matching[Match Signs<br/>to Text]
        alphabetQuiz --> camera2[Fingerspell<br/>Letters]
        
        camera1 --> results[Quiz<br/>Results]
        matching --> results
        camera2 --> results
        results --> badges[Update Badges<br/>& Progress]
        badges --> dashboard
        
        practice --> cameraMode[Camera Practice<br/>Mode]
        cameraMode --> realTime[Real-time Sign<br/>Recognition]
        realTime --> feedback[Live<br/>Feedback]
        feedback --> practice
        
        phrases --> phraseList[Phrase<br/>Library]
        phrases --> signsList[Signs<br/>Library]
        signsList --> signsDetial[View Signs<br/>Details]
        phraseList --> purchasePhrase{Purchase<br/>Required?}
        purchasePhrase -->|Yes| buyPhrase[Buy with Virtual<br/>Currency]
        purchasePhrase -->|No| viewPhrase[View Phrase<br/>Details]
        buyPhrase --> viewPhrase
        viewPhrase --> learnSigns[Learn Individual<br/>Signs]
        learnSigns --> signsDetial
        
        explore --> extrasCategories[Browse Content<br/>Categories]
        extrasCategories --> articles[Articles]
        extrasCategories --> podcasts[Podcasts]
        extrasCategories --> events[Events]
        extrasCategories --> etc[etc]
        
        profile --> viewBadges[View Earned<br/>Badges]
        profile --> streakInfo[View Learning<br/>Streak]
        profile --> buyFreeze[Buy Streak<br/>Freeze]
        profile --> settings[App<br/>Settings]
        profile --> referralCode[Share Referral<br/>Code]
        
        streakInfo --> calendar[Streak Calendar<br/>View]
        buyFreeze --> spendMoney[Spend Virtual<br/>Currency]
        settings --> notifications[Customize<br/>Notifications]
    end
    
    subgraph "Gamification System"
        results --> updateLevel[Update User<br/>Level]
        results --> earnMoney[Earn Virtual<br/>Currency]
        results --> updateStreak[Update Daily<br/>Streak]
        updateLevel --> checkBadges[Check Badge<br/>Progress]
        checkBadges --> unlockBadge[Unlock New<br/>Badges]
        unlockBadge --> dashboard
    end

    style start fill:#4CAF50,stroke:#333,stroke-width:2px,color:white
    style dashboard fill:#2196F3,stroke:#333,stroke-width:2px,color:white
    style camera1 fill:#FF5722,stroke:#333,stroke-width:2px,color:white
    style camera2 fill:#FF5722,stroke:#333,stroke-width:2px,color:white
    style cameraMode fill:#FF5722,stroke:#333,stroke-width:2px,color:white
    style results fill:#9C27B0,stroke:#333,stroke-width:2px,color:white
    style badges fill:#FF9800,stroke:#333,stroke-width:2px,color:white
```

## User Flow Components

### Authentication & Onboarding
- **Registration**: New users create accounts with optional referral codes for rewards
- **Sign In**: Existing users authenticate with username/email and password
- **Referral System**: Users can benefit from referral codes and share their own

### Core Learning Features
- **Quizzes Tab**: Access to various quiz types (Bubbles, Matching, Alphabet Streak)
- **Camera Tab**: Real-time camera-based sign recognition practice
- **Wiki Tab**: Browse phrase and sign libraries, purchase phrases using virtual currency
- **Explore Tab**: Educational content including articles, podcasts, events, and media

### Gamification Elements
- **Badge System**: Achievement tracking with Bronze, Silver, and Gold rarities
- **Streak System**: Daily learning streaks with freeze purchase options
- **Virtual Currency**: Earned through quizzes and spent on phrases/streak freezes
- **Level Progression**: User advancement based on quiz performance

### Camera Integration
- **Real-time Recognition**: Uses MediaPipe for hand landmark detection
- **Multiple Models**: Simple ASL classifier and Alphabet-specific models
- **Live Feedback**: Immediate visual feedback during practice sessions

The flow emphasizes the app's core value proposition of interactive ASL learning through camera-based recognition, gamified progression, and comprehensive educational content.
The flow emphasizes the app's core value proposition of interactive ASL learning through camera-based recognition, gamified progression, and comprehensive educational content.
