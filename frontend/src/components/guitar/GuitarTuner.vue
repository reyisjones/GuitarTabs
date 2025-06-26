<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue';

// Define standard guitar tuning frequencies
const STANDARD_TUNING = {
  E4: 329.63,
  B3: 246.94,
  G3: 196.00,
  D3: 146.83,
  A2: 110.00,
  E2: 82.41
};

const strings = ref([
  { note: 'E4', freq: STANDARD_TUNING.E4, isPlaying: false },
  { note: 'B3', freq: STANDARD_TUNING.B3, isPlaying: false },
  { note: 'G3', freq: STANDARD_TUNING.G3, isPlaying: false },
  { note: 'D3', freq: STANDARD_TUNING.D3, isPlaying: false },
  { note: 'A2', freq: STANDARD_TUNING.A2, isPlaying: false },
  { note: 'E2', freq: STANDARD_TUNING.E2, isPlaying: false }
]);

// Right-handed by default
const isLeftHanded = ref(false);

// Web Audio API components
let audioContext: AudioContext | null = null;
const oscillators: { [note: string]: OscillatorNode | null } = {};
const gains: { [note: string]: GainNode | null } = {};

// Initialize Audio Context
onMounted(() => {
  audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
  
  // Initialize oscillators and gain nodes for each string
  strings.value.forEach(string => {
    if (!audioContext) return;
    
    // Create oscillator
    const oscillator = audioContext.createOscillator();
    oscillator.type = 'sine';
    oscillator.frequency.value = string.freq;
    
    // Create gain node (volume control)
    const gainNode = audioContext.createGain();
    gainNode.gain.value = 0; // Start with volume at 0
    
    // Connect nodes
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    // Start oscillator (it will run silently until we increase the gain)
    oscillator.start();
    
    // Store references
    oscillators[string.note] = oscillator;
    gains[string.note] = gainNode;
  });
});

// Clean up on component destroy
onBeforeUnmount(() => {
  // Stop and disconnect all oscillators
  Object.values(oscillators).forEach(osc => {
    if (osc) {
      osc.stop();
      osc.disconnect();
    }
  });
  
  // Disconnect all gain nodes
  Object.values(gains).forEach(gain => {
    if (gain) {
      gain.disconnect();
    }
  });
  
  // Close audio context
  if (audioContext && audioContext.state !== 'closed') {
    audioContext.close();
  }
});

// Play a string sound
function playString(index: number) {
  const string = strings.value[index];
  
  if (!string || !audioContext || !gains[string.note]) {
    return;
  }
  
  // Update state
  strings.value[index].isPlaying = true;
  
  // Get gain node
  const gainNode = gains[string.note];
  if (!gainNode) return;
  
  // Set attack (quick ramp up)
  gainNode.gain.setValueAtTime(0, audioContext.currentTime);
  gainNode.gain.linearRampToValueAtTime(0.5, audioContext.currentTime + 0.01);
  
  // Set decay and sustain
  gainNode.gain.linearRampToValueAtTime(0.3, audioContext.currentTime + 0.2);
  
  // Set release (gradual fade out)
  gainNode.gain.linearRampToValueAtTime(0, audioContext.currentTime + 2.5);
  
  // Update state after sound finishes
  setTimeout(() => {
    strings.value[index].isPlaying = false;
  }, 2500);
}

// Toggle between left and right hand mode
function toggleHandedness() {
  isLeftHanded.value = !isLeftHanded.value;
}

defineExpose({
  playString,
  toggleHandedness
});
</script>

<template>
  <div class="guitar-tuner">
    <h2>Guitar Tuner</h2>
    
    <div class="controls">
      <button @click="toggleHandedness" class="handedness-button">
        {{ isLeftHanded ? 'Switch to Right-Handed' : 'Switch to Left-Handed' }}
      </button>
    </div>
    
    <div :class="['guitar-neck', { 'left-handed': isLeftHanded }]">
      <div 
        v-for="(string, index) in strings" 
        :key="string.note"
        :class="['guitar-string', { 'playing': string.isPlaying }]"
        @click="playString(index)"
      >
        <div class="string-line"></div>
        <div class="note-label">{{ string.note }}</div>
      </div>
    </div>
    
    <div class="instructions">
      <p>Click on any string to hear its tuning note.</p>
    </div>
  </div>
</template>

<style scoped>
.guitar-tuner {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #f9f9f9;
}

.controls {
  margin-bottom: 20px;
  text-align: right;
}

.handedness-button {
  padding: 8px 12px;
  background-color: #4a90e2;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.handedness-button:hover {
  background-color: #3a80d2;
}

.guitar-neck {
  position: relative;
  width: 100%;
  background-color: #8B4513; /* Brown wood color */
  border-radius: 5px;
  padding: 20px 10px;
  margin-bottom: 20px;
}

.guitar-string {
  position: relative;
  height: 40px;
  margin: 15px 0;
  cursor: pointer;
  transition: all 0.3s ease;
}

.string-line {
  position: absolute;
  width: 100%;
  height: 2px;
  background-color: #e0e0e0;
  top: 50%;
  transform: translateY(-50%);
}

.guitar-string:nth-child(1) .string-line { height: 1px; }
.guitar-string:nth-child(2) .string-line { height: 1.5px; }
.guitar-string:nth-child(3) .string-line { height: 2px; }
.guitar-string:nth-child(4) .string-line { height: 2.5px; }
.guitar-string:nth-child(5) .string-line { height: 3px; }
.guitar-string:nth-child(6) .string-line { height: 3.5px; }

.note-label {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
  background-color: #333;
  color: white;
  padding: 5px 10px;
  border-radius: 15px;
  font-weight: bold;
}

.left-handed .note-label {
  right: auto;
  left: 15px;
}

.guitar-string.playing .string-line {
  background-color: #ffcc00;
  box-shadow: 0 0 10px #ffcc00;
  animation: vibrate 0.5s ease-in-out;
}

@keyframes vibrate {
  0%, 100% { transform: translateY(-50%); }
  25% { transform: translateY(-55%); }
  75% { transform: translateY(-45%); }
}

.instructions {
  text-align: center;
  color: #666;
  font-style: italic;
}
</style>
