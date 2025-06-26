<script setup lang="ts">
import { RouterLink } from 'vue-router';
</script>

<template>
  <main class="home">
    <div class="hero">
      <h1>Welcome to Guitar Tabs Player</h1>
      <p class="tagline">Play, learn, and master your favorite guitar tablatures</p>
      
      <div class="actions">
        <RouterLink to="/tabs" class="btn btn-primary">Start Playing Tabs</RouterLink>
        <RouterLink to="/tuner" class="btn btn-secondary">Tune Your Guitar</RouterLink>
      </div>
    </div>
    
    <div class="features">
      <h2>Features</h2>
      
      <div class="feature-grid">
        <div class="feature-card">
          <div class="feature-icon">🎵</div>
          <h3>Tab Player</h3>
          <p>Upload and play Guitar Pro files with accurate tablature display and playback</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">🎤</div>
          <h3>Karaoke Mode</h3>
          <p>Follow along with highlighted notation as the music plays</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">🎚️</div>
          <h3>Playback Control</h3>
          <p>Adjust tempo, volume, and set loop points to practice difficult sections</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">🎸</div>
          <h3>Guitar Tuner</h3>
          <p>Built-in tuner helps you get your instrument ready to play</p>
        </div>
      </div>
    </div>
    
    <div class="get-started">
      <h2>How to Get Started</h2>
      <ol class="steps">
        <li>
          <strong>Upload a Tab File</strong>
          <p>Go to the Tab Player and upload your .gp, .gpx, .gp5, or .musicxml file</p>
        </li>
        <li>
          <strong>Tune Your Guitar</strong>
          <p>Use the built-in tuner to make sure your guitar is perfectly in tune</p>
        </li>
        <li>
          <strong>Play Along</strong>
          <p>Play the tab and follow along with the highlighted notation</p>
        </li>
        <li>
          <strong>Practice Difficult Parts</strong>
          <p>Use the loop feature and slow down the tempo to master challenging sections</p>
        </li>
      </ol>
    </div>
  </main>
</template>

<style scoped>
.home {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.hero {
  text-align: center;
  padding: 40px 20px;
  margin-bottom: 40px;
  background: linear-gradient(to right, #f0f4ff, #e5edff);
  border-radius: 12px;
}

.hero h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  color: #2c3e50;
}

.tagline {
  font-size: 1.2rem;
  color: #5a6d85;
  margin-bottom: 30px;
}

.actions {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.btn {
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: bold;
  text-decoration: none;
  transition: all 0.3s ease;
}

.btn-primary {
  background-color: #4a90e2;
  color: white;
}

.btn-primary:hover {
  background-color: #3a7bc8;
}

.btn-secondary {
  background-color: #e0e0e0;
  color: #333;
}

.btn-secondary:hover {
  background-color: #d0d0d0;
}

.features {
  margin-bottom: 50px;
}

.features h2 {
  text-align: center;
  margin-bottom: 30px;
  color: #2c3e50;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.feature-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 25px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.feature-icon {
  font-size: 2.5rem;
  margin-bottom: 15px;
}

.feature-card h3 {
  margin-bottom: 10px;
  color: #2c3e50;
}

.feature-card p {
  color: #5a6d85;
  line-height: 1.5;
}

.get-started {
  background-color: #f9f9f9;
  padding: 30px;
  border-radius: 12px;
}

.get-started h2 {
  text-align: center;
  margin-bottom: 30px;
  color: #2c3e50;
}

.steps {
  counter-reset: step-counter;
  list-style-type: none;
  padding: 0;
}

.steps li {
  position: relative;
  padding-left: 50px;
  margin-bottom: 30px;
}

.steps li:before {
  content: counter(step-counter);
  counter-increment: step-counter;
  position: absolute;
  left: 0;
  top: 0;
  background-color: #4a90e2;
  color: white;
  width: 35px;
  height: 35px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.steps li strong {
  display: block;
  margin-bottom: 5px;
  font-size: 1.1rem;
  color: #2c3e50;
}

.steps li p {
  color: #5a6d85;
  line-height: 1.5;
}

@media (max-width: 768px) {
  .hero h1 {
    font-size: 2rem;
  }
  
  .actions {
    flex-direction: column;
  }
  
  .feature-grid {
    grid-template-columns: 1fr;
  }
}
</style>
