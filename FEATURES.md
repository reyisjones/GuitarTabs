# Guitar Tabs Player - Features Documentation

This document provides detailed information about the features and components of the Guitar Tabs Player application.

## Table of Contents

1. [Tab Player](#tab-player)
2. [Guitar Tuner](#guitar-tuner)
3. [Karaoke Mode](#karaoke-mode)
4. [File Management](#file-management)
5. [Component Architecture](#component-architecture)
6. [Technical Implementation](#technical-implementation)

## Tab Player

The Tab Player is the core feature of the application that displays and plays guitar tablatures.

### Capabilities

- **Tablature Display**: Renders guitar tabs in standard notation and tablature format
- **Audio Playback**: Plays back notes using high-quality SoundFont synthesis
- **Track Control**: Enable/disable individual instrument tracks
- **Playback Controls**: Play, pause, stop functionality
- **Tempo Adjustment**: Speed up or slow down playback (50%-200%)
- **Volume Control**: Adjust master volume level
- **Loop Mode**: Set loop points to practice specific sections

### Implementation Details

The Tab Player is built using the [AlphaTab](https://www.alphatab.net/) library with a custom Vue.js wrapper component. Key technical aspects include:

- Dynamic loading of AlphaTab via ES modules
- Responsive layout adaptation for different screen sizes
- Custom event handling for player state changes
- WebAssembly integration for optimal performance
- Custom styling compatible with dark/light mode

### Usage Example

```vue
<TabPlayer 
  :file="tabFileUrl" 
  :settings="{ 
    display: { scale: 1.2 },
    player: { soundFont: 'custom-soundfont.sf2' }
  }"
  @loaded="onTabLoaded" 
/>
```

## Guitar Tuner

An interactive tool for tuning a guitar to standard tuning (E A D G B E).

### Capabilities

- **Reference Tones**: Plays pure sine waves for each string
- **Visual Feedback**: Shows active string being played
- **Left/Right Hand Mode**: Adapts display for left-handed players
- **Responsive Design**: Works on desktop and mobile devices

### Implementation Details

The Guitar Tuner uses the Web Audio API to generate precise reference tones:

- AudioContext for generating pure sine waves
- OscillatorNode with precise frequency values
- GainNode for smooth attack and decay of notes
- Visual feedback synchronized with audio playback

### Usage Example

```vue
<GuitarTuner 
  :isLeftHanded="false" 
  @stringPlayed="onStringPlayed" 
/>
```

## Karaoke Mode

The Karaoke Mode synchronizes visual highlighting with audio playback to help users follow along.

### Capabilities

- **Note Highlighting**: Highlights current notes being played
- **Auto-Scroll**: Automatically scrolls to the current position
- **Beat Indicators**: Visual metronome showing beat positions
- **Section Markers**: Displays rehearsal markers and section names

### Implementation Details

Karaoke Mode is implemented by integrating with AlphaTab's event system:

- Uses `beatChanged` events to track current position
- Custom CSS for highlighting current notes
- Smooth scrolling algorithms for optimal viewing
- Configurable highlight colors and effects

## File Management

The file management system handles uploading, storing, and retrieving tablature files.

### Capabilities

- **File Upload**: Supports .gp, .gpx, .gp5, and .musicxml formats
- **File Listing**: Displays uploaded tabs with metadata
- **Delete Function**: Remove tabs from the library
- **Metadata Extraction**: Shows title, artist, and creation date

### Implementation Details

- Flask backend REST API for file operations
- JWT-based authentication for secure access
- File format validation before storage
- Unique identifiers for each uploaded file
- Structured metadata storage for efficient retrieval

## Component Architecture

The application follows a modular component architecture for maintainability and reusability.

### Core Components

1. **TabPlayer.vue**: Main component for displaying and playing tabs
2. **GuitarTuner.vue**: Interactive guitar tuning component
3. **TabFileUploader.vue**: File upload component with drag-and-drop support
4. **TabsView.vue**: Main view for the tab player functionality
5. **TunerView.vue**: Dedicated view for the guitar tuner

### State Management

- Pinia store for application-wide state management
- Reactive data flow between components
- Persistent storage for user preferences

## Technical Implementation

### Frontend

- **Framework**: Vue.js 3 with Composition API
- **Language**: TypeScript for type safety
- **Styling**: Scoped CSS with responsive design
- **Build Tool**: Vite for fast development
- **Package Manager**: Bun for improved performance
- **Component Documentation**: Storybook for visual testing

### Backend

- **Framework**: Flask with RESTful API design
- **WebSockets**: Flask-SocketIO for real-time communication
- **Authentication**: JWT-based token system
- **File Handling**: Secure file uploads with validation
- **Containerization**: Docker for consistent deployment

### Performance Optimizations

- Lazy loading of routes and components
- Code splitting for reduced initial load time
- Asset optimization for faster loading
- Caching strategies for API responses
- WebP image format for improved loading speed

### Accessibility Features

- Keyboard navigation support
- Screen reader compatibility
- ARIA attributes for interactive elements
- Color contrast compliance
- Focus management for keyboard users

---

For more information on implementation details or custom configurations, please refer to the code documentation or contact the development team.
