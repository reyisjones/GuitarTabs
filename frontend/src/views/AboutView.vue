<template>
  <div class="about">
    <div class="about-content">
      <h1>About Guitar Tabs Player</h1>
      
      <section class="section">
        <h2>What is Guitar Tabs Player?</h2>
        <p>
          Guitar Tabs Player is a web application designed to help guitarists of all levels practice, 
          learn, and master their favorite songs. Our application uses the powerful AlphaTab library 
          to render and play guitar tablature files with high precision.
        </p>
      </section>
      
      <section class="section">
        <h2>Technologies Used</h2>
        <div class="tech-grid">
          <div class="tech-item">
            <h3>Frontend</h3>
            <ul>
              <li>Vue.js 3 with TypeScript</li>
              <li>AlphaTab for tablature rendering and playback</li>
              <li>Web Audio API for the Guitar Tuner</li>
              <li>Storybook for component documentation</li>
            </ul>
          </div>
          
          <div class="tech-item">
            <h3>Backend</h3>
            <ul>
              <li>Python with Flask</li>
              <li>WebSockets for real-time communication</li>
              <li>RESTful API for file management</li>
              <li>Docker for containerization</li>
            </ul>
          </div>
          
          <div class="tech-item">
            <h3>Deployment</h3>
            <ul>
              <li>CI/CD with GitHub Actions</li>
              <li>Azure Container Registry</li>
              <li>Azure Web App for Containers</li>
              <li>Azure Front Door for global routing</li>
            </ul>
          </div>
        </div>
      </section>
      
      <section class="section">
        <h2>Supported File Formats</h2>
        <p>
          Guitar Tabs Player supports the following tablature file formats:
        </p>
        <ul class="format-list">
          <li><strong>.gp</strong> - Guitar Pro files</li>
          <li><strong>.gpx</strong> - Guitar Pro 6 files</li>
          <li><strong>.gp5</strong> - Guitar Pro 5 files</li>
          <li><strong>.musicxml</strong> - MusicXML files</li>
        </ul>
      </section>
      
      <section class="section">
        <h2>Get in Touch</h2>
        <p>
          Have questions, suggestions, or feedback? We'd love to hear from you!
        </p>
        <div class="contact-info">
          <p><strong>Email:</strong> <a href="mailto:contact@guitartabsplayer.com">contact@guitartabsplayer.com</a></p>
          <p><strong>GitHub:</strong> <a href="https://github.com/guitartabsplayer" target="_blank">github.com/guitartabsplayer</a></p>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.about {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.about-content {
  background-color: #fff;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.section {
  margin-bottom: 40px;
}

h1 {
  text-align: center;
  margin-bottom: 40px;
  color: #2c3e50;
}

h2 {
  color: #4a90e2;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #eee;
}

p {
  line-height: 1.6;
  color: #444;
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 30px;
}

.tech-item {
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 8px;
}

.tech-item h3 {
  margin-bottom: 15px;
  color: #2c3e50;
}

ul {
  padding-left: 20px;
}

li {
  margin-bottom: 8px;
  line-height: 1.5;
}

.format-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  list-style: none;
  padding: 0;
}

.format-list li {
  background-color: #f0f4ff;
  padding: 10px 15px;
  border-radius: 6px;
}

.contact-info {
  background-color: #f9f9f9;
  padding: 20px;
  border-radius: 8px;
  text-align: center;
}

.contact-info a {
  color: #4a90e2;
  text-decoration: none;
}

.contact-info a:hover {
  text-decoration: underline;
}

@media (max-width: 768px) {
  .about-content {
    padding: 20px;
  }
  
  .tech-grid {
    grid-template-columns: 1fr;
  }
}
</style>
