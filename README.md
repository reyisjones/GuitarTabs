# 🎸 Guitar Tabs Player

A modern, full-stack web application for guitar enthusiasts to upload, view, and play guitar tablatures with interactive features and professional audio playback.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.0-green.svg)](https://vuejs.org/)
[![Flask](https://img.shields.io/badge/Flask-2.0-blue.svg)](https://flask.palletsprojects.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

## 🌟 Features

### 🎵 Core Guitar Features
- **📁 Tab File Support**: Upload and play Guitar Pro files (.gp3, .gp4, .gp5, .gpx)
- **🎼 Interactive Tab Display**: Professional tablature rendering with AlphaTab integration
- **🔊 Audio Playback**: High-quality MIDI playback with tempo and volume controls
- **🎚️ Guitar Tuner**: Built-in chromatic tuner for guitar tuning
- **⏯️ Playback Controls**: Play, pause, loop, and seek through tablatures
- **📱 Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices

### 🔐 User Management
- **👤 User Authentication**: Secure registration and login system
- **🔑 JWT Security**: Token-based authentication with refresh capabilities
- **📂 Personal Library**: Organize and manage your guitar tab collection
- **🎯 User Profiles**: Customizable user experience and preferences

### 🛠️ Technical Features
- **⚡ Modern Frontend**: Vue.js 3 with TypeScript and Composition API
- **🔧 RESTful API**: Flask backend with comprehensive API endpoints
- **☁️ Cloud Ready**: Azure deployment with Infrastructure as Code
- **🐳 Containerized**: Docker support for development and production
- **🔄 CI/CD**: GitHub Actions for automated testing and deployment
- **📊 Development Tools**: Storybook for component development and testing

## 🏗️ Architecture

### Frontend (Vue.js + TypeScript)
```
frontend/
├── src/
│   ├── components/
│   │   ├── auth/           # Authentication components
│   │   └── guitar/         # Guitar-specific components
│   ├── views/              # Page components
│   ├── stores/             # Pinia state management
│   ├── router/             # Vue Router configuration
│   └── utils/              # API and utility functions
├── public/
│   └── assets/alphatab/    # AlphaTab resources (fonts, soundfonts)
└── docker/                 # Docker configuration
```

### Backend (Flask + Python)
```
backend/
├── app.py                  # Main Flask application
├── models/                 # Data models and business logic
├── tests/                  # Unit and integration tests
├── data/                   # Data storage (JSON-based)
└── uploads/                # User-uploaded tab files
```

### Infrastructure (Azure)
```
infrastructure/
├── main.bicep              # Azure Bicep templates
├── deploy.ps1              # PowerShell deployment script
└── deploy.sh               # Bash deployment script
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** 18+ 
- **Python** 3.9+
- **Docker** (optional, for containerized development)

### 🔧 Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/reyisjones/GuitarTabs.git
   cd GuitarTabs
   ```

2. **Setup Backend**
   ```bash
   cd backend
   cp .env.example .env
   # Edit .env with your configuration
   pip install -r requirements.txt
   python app.py
   ```

3. **Setup Frontend**
   ```bash
   cd frontend
   cp .env.example .env
   # Edit .env with your API URL
   npm install
   npm run dev
   ```

4. **Access Application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:5000

### 🐳 Docker Development

Use the provided startup scripts for quick Docker setup:

**Windows:**
```powershell
.\StartApp.bat
# or with GUI
.\StartAppGUI.ps1
```

**macOS/Linux:**
```bash
./start-app.sh
```

## 🎯 Usage

### Upload Guitar Tabs
1. Register/Login to your account
2. Navigate to the "Tabs" section
3. Click "Upload Tab" and select your Guitar Pro file
4. Your tab will be processed and added to your library

### Play Tabs
1. Select a tab from your library
2. Use the interactive player controls:
   - **Play/Pause**: Control playback
   - **Tempo**: Adjust playback speed
   - **Volume**: Control audio level
   - **Loop**: Set loop points for practice

### Tune Your Guitar
1. Go to the "Tuner" section
2. Allow microphone access
3. Play each string and tune according to the visual feedback

## 🔧 Configuration

### Environment Variables

**Backend (.env)**
```bash
SECRET_KEY=your_strong_secret_key_here
JWT_SECRET_KEY=your_jwt_secret_key_here
UPLOAD_FOLDER=uploads
PORT=5000
FLASK_ENV=development
```

**Frontend (.env)**
```bash
VITE_API_URL=http://localhost:5000
```

### Production Deployment

The application is designed for Azure deployment with:
- **Azure Container Instances** for hosting
- **Azure Key Vault** for secrets management
- **Azure Container Registry** for image storage

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/refresh` - Token refresh

### Tab Management Endpoints
- `GET /api/tabs` - List user's tabs
- `POST /api/upload` - Upload new tab file
- `GET /api/tabs/:id` - Get specific tab
- `DELETE /api/tabs/:id` - Delete tab

### User Endpoints
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile

## 🧪 Testing

**Backend Tests**
```bash
cd backend
python -m pytest tests/
```

**Frontend Tests**
```bash
cd frontend
npm run test
```

**End-to-End Tests**
```bash
npm run test:e2e
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style and conventions
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📁 Project Structure

```
GuitarTabs/
├── 📁 backend/             # Flask API server
├── 📁 frontend/            # Vue.js application
├── 📁 infrastructure/      # Azure deployment templates
├── 📁 .github/workflows/   # CI/CD automation
├── 📄 FEATURES.md          # Detailed feature documentation
├── 📄 DEPLOYMENT.md        # Deployment instructions
├── 📄 STARTUP.md           # Setup guide
├── 📄 TROUBLESHOOTING.md   # Common issues and solutions
└── 📄 README.md            # This file
```

## 🔒 Security

This project follows security best practices:
- ✅ JWT-based authentication
- ✅ Environment variable configuration
- ✅ Input validation and sanitization
- ✅ Secure file upload handling
- ✅ CORS configuration
- ✅ No hardcoded secrets in codebase

For security concerns, please see our [Security Policy](SECURITY.md).

## 📈 Roadmap

### Planned Features
- [ ] **Real-time Collaboration**: Share and collaborate on tabs
- [ ] **Mobile App**: Native iOS and Android applications
- [ ] **Advanced Editor**: Built-in tab editing capabilities
- [ ] **Social Features**: Share tabs with the community
- [ ] **Practice Tools**: Metronome, slow-down features
- [ ] **Export Options**: PDF and MIDI export functionality

### Technical Improvements
- [ ] **Database Integration**: PostgreSQL/MongoDB support
- [ ] **Caching Layer**: Redis for improved performance
- [ ] **WebSocket Support**: Real-time features
- [ ] **Offline Support**: PWA capabilities
- [ ] **Analytics**: Usage tracking and insights

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[AlphaTab](https://alphatab.net/)** - Excellent web-based guitar tablature rendering
- **[Vue.js](https://vuejs.org/)** - Progressive JavaScript framework
- **[Flask](https://flask.palletsprojects.com/)** - Lightweight Python web framework
- **[Azure](https://azure.microsoft.com/)** - Cloud infrastructure platform

## 📞 Support

- **Documentation**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- **Issues**: Report bugs via [GitHub Issues](https://github.com/reyisjones/GuitarTabs/issues)
- **Discussions**: Join conversations in [GitHub Discussions](https://github.com/reyisjones/GuitarTabs/discussions)

---

<div align="center">

**Built with ❤️ for the guitar community**

[🌐 Live Demo](https://your-demo-url.com) • [📖 Documentation](https://github.com/reyisjones/GuitarTabs/wiki) • [🐛 Report Bug](https://github.com/reyisjones/GuitarTabs/issues)

</div>
