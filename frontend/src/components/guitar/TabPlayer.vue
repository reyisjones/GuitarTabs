<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';
import type { PropType } from 'vue';
// We'll import AlphaTab dynamically to have full control over initialization

// Define props
const props = defineProps({
  file: {
    type: String,
    default: ''
  },
  settings: {
    type: Object as PropType<Record<string, any>>,
    default: () => ({})
  }
});

// Emit events
const emit = defineEmits(['ready', 'loaded', 'playerReady', 'playerStateChanged', 'soundFontLoaded', 'soundFontLoadFailed']);

// Create refs
const tabContainer = ref<HTMLDivElement | null>(null);
// Define a more generic type for the API since we're dynamically importing it
const api = ref<any>(null);
const isPlaying = ref(false);
const currentBeat = ref(0);
const tempo = ref(100);
const volume = ref(1.0);
const isLoopActive = ref(false);
const loopStart = ref(0);
const loopEnd = ref(0);
const songDuration = ref(0);
const songPosition = ref(0);

// Track to display elapsed time
let timeDisplayInterval: number | null = null;

// Initialize AlphaTab
onMounted(async () => {
  if (!tabContainer.value) return;
  try {
    // Dynamically import AlphaTab
    const alphaTabModule = await import('@coderline/alphatab');
    
    // Create settings - use any type to avoid TypeScript errors with dynamically loaded module
    const defaultSettings: Record<string, any> = {
      core: {
        // Configure AlphaTab resources
        fontDirectory: '/assets/alphatab/font/',
        scriptFile: null, // Disable worker to avoid MIME issues
        useWorkers: false // Explicitly disable workers
      },
      display: {
        layoutMode: alphaTabModule.LayoutMode.Page,
        staveProfile: alphaTabModule.StaveProfile.ScoreTab,
        scale: 1.0,
        resources: {
          // Use proper property names expected by AlphaTab
          fontDirectory: '/assets/alphatab/font/',
          // Gracefully handle loading failures in our error handling
        }
      },
      player: {
        enablePlayer: true,
        // Try multiple paths to ensure soundfonts are loaded correctly
        soundFont: '/assets/alphatab/soundfont/sonivox.sf2',
        // Use proper scrolling element reference
        scrollElement: document.documentElement // Use documentElement instead of window
      }
    };

  // Initialize API
  api.value = new alphaTabModule.AlphaTabApi(tabContainer.value, {
    ...defaultSettings,
    ...props.settings
  });

  // Set initial tempo
  tempo.value = api.value.playbackSpeed * 100;
  volume.value = api.value.masterVolume;

  // Register event listeners
  setupEventListeners();

  // Load file if provided
  if (props.file) {
    loadFile(props.file);
  }
  // Emit ready event
  emit('ready', api.value);
  } catch (error) {
    console.error('Error initializing AlphaTab:', error);
    // Add error message to the UI
    if (tabContainer.value) {
      tabContainer.value.innerHTML = `
        <div style="color: red; padding: 20px;">
          <h3>Error loading the tab player</h3>
          <p>Please try refreshing the page or check your network connection.</p>
          <details>
            <summary>Technical details</summary>
            <pre>${error instanceof Error ? error.message : String(error)}</pre>
          </details>
        </div>
      `;
    }
  }
});

// Clean up on component destroy
onBeforeUnmount(() => {
  cleanupEventListeners();
  cleanupTimeInterval();
  api.value?.destroy();
});

// Watch for file changes
watch(() => props.file, (newFile) => {
  if (newFile && api.value) {
    loadFile(newFile);
  }
});

// Watch for tempo changes
watch(() => tempo.value, (newTempo) => {
  if (api.value) {
    api.value.playbackSpeed = newTempo / 100;
  }
});

// Watch for volume changes
watch(() => volume.value, (newVolume) => {
  if (api.value) {
    api.value.masterVolume = newVolume;
  }
});

// Setup event listeners
function setupEventListeners() {
  if (!api.value) return;
  // Check if each event property exists before adding listeners
  if (api.value.scoreLoaded) {
    api.value.scoreLoaded.on((score: any) => {
      songDuration.value = api.value?.totalDuration || 0;
      emit('loaded', score);
    });
  }

  if (api.value.playerReady) {
    api.value.playerReady.on(() => {
      emit('playerReady');
    });
  }

  if (api.value.playerStateChanged) {
    api.value.playerStateChanged.on((state: number) => {
      isPlaying.value = state === 1; // 1 = Playing
      
      if (isPlaying.value) {
        setupTimeInterval();
      } else {
        cleanupTimeInterval();
      }
      
      emit('playerStateChanged', state);
    });
  }

  if (api.value.soundFontLoaded) {
    api.value.soundFontLoaded.on(() => {
      emit('soundFontLoaded');
    });
  }

  if (api.value.soundFontLoadFailed) {
    api.value.soundFontLoadFailed.on((e: Error) => {
      emit('soundFontLoadFailed', e);
      console.warn('SoundFont failed to load:', e);
    });
  }

  if (api.value.beatChanged) {
    api.value.beatChanged.on((beat: { index: number }) => {
      currentBeat.value = beat.index;
    });
  }
}

// Clean up event listeners
function cleanupEventListeners() {
  if (!api.value) return;

  // AlphaTab automatically cleans up event listeners on destroy
}

// Load a file
function loadFile(file: string) {
  if (!api.value) return;
  
  isPlaying.value = false;
  currentBeat.value = 0;
  
  if (file.startsWith('http') || file.startsWith('blob:')) {
    api.value.load(file);
  } else {
    // Assume it's a base64 string
    try {
      api.value.loadBase64(file);
    } catch (e) {
      console.error('Failed to load file:', e);
    }
  }
}

// Play/pause toggle
function togglePlay() {
  if (!api.value) return;
  
  if (isPlaying.value) {
    api.value.pause();
  } else {
    api.value.play();
  }
}

// Stop playback
function stop() {
  if (!api.value) return;
  api.value.stop();
  isPlaying.value = false;
}

// Set loop points
function setLoopPoints(start: number, end: number) {
  if (!api.value) return;
  
  loopStart.value = start;
  loopEnd.value = end;
  
  if (start >= 0 && end > start) {
    isLoopActive.value = true;
    api.value.playbackRange = [start, end];
  } else {
    clearLoop();
  }
}

// Clear loop
function clearLoop() {
  if (!api.value) return;
  
  isLoopActive.value = false;
  loopStart.value = 0;
  loopEnd.value = 0;
  api.value.playbackRange = null;
}

// Toggle loop
function toggleLoop() {
  isLoopActive.value = !isLoopActive.value;
  
  if (isLoopActive.value) {
    if (loopStart.value === 0 && loopEnd.value === 0 && api.value) {
      // Default to looping the current measure if no loop points are set
      const currentMeasure = api.value.tickPosition;
      const nextMeasure = api.value.tickPositionToTimePosition(currentMeasure + api.value.timeSignatureNumerator * 960);
      setLoopPoints(currentMeasure, nextMeasure);
    } else {
      setLoopPoints(loopStart.value, loopEnd.value);
    }
  } else {
    clearLoop();
  }
}

// Setup interval to track elapsed time
function setupTimeInterval() {
  cleanupTimeInterval();
  timeDisplayInterval = window.setInterval(() => {
    if (api.value) {
      songPosition.value = api.value.playbackPos;
    }
  }, 100);
}

// Clean up time interval
function cleanupTimeInterval() {
  if (timeDisplayInterval !== null) {
    window.clearInterval(timeDisplayInterval);
    timeDisplayInterval = null;
  }
}

// Format time in MM:SS format
function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// Expose public methods
defineExpose({
  play: () => api.value?.play(),
  pause: () => api.value?.pause(),
  stop,
  togglePlay,
  setLoopPoints,
  clearLoop,
  toggleLoop,
  api
});
</script>

<template>
  <div class="tab-player">
    <!-- AlphaTab Container -->
    <div ref="tabContainer" class="alphatab-container"></div>
    
    <!-- Player Controls -->
    <div class="controls">
      <div class="transport-controls">
        <button @click="togglePlay" class="control-button">
          <span v-if="isPlaying">⏸️</span>
          <span v-else>▶️</span>
        </button>
        <button @click="stop" class="control-button">⏹️</button>
        <button @click="toggleLoop" :class="['control-button', { active: isLoopActive }]">🔄</button>
      </div>
      
      <div class="time-display">
        {{ formatTime(songPosition) }} / {{ formatTime(songDuration) }}
      </div>
      
      <div class="sliders">
        <label>
          Speed:
          <input type="range" min="50" max="200" v-model.number="tempo" class="slider" />
          {{ tempo }}%
        </label>
        
        <label>
          Volume:
          <input type="range" min="0" max="1" step="0.01" v-model.number="volume" class="slider" />
        </label>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tab-player {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-height: 400px;
  border: 1px solid #ccc;
  border-radius: 4px;
  overflow: hidden;
}

.alphatab-container {
  flex: 1;
  min-height: 350px;
  overflow: auto;
  padding: 10px;
  background-color: white;
}

.controls {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  padding: 10px;
  background-color: #f5f5f5;
  border-top: 1px solid #ddd;
}

.transport-controls {
  display: flex;
  gap: 5px;
}

.control-button {
  padding: 8px 12px;
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

.control-button:hover {
  background-color: #eee;
}

.control-button.active {
  background-color: #e0e0ff;
}

.time-display {
  font-family: monospace;
  font-size: 14px;
  margin: 0 10px;
}

.sliders {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  align-items: center;
}

.sliders label {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
}

.slider {
  width: 100px;
}

@media (max-width: 768px) {
  .controls {
    flex-direction: column;
    gap: 10px;
  }
  
  .transport-controls,
  .sliders {
    width: 100%;
    justify-content: center;
  }
  
  .time-display {
    margin: 5px 0;
  }
}
</style>
